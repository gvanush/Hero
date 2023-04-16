//
//  CompTreeView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.03.23.
//

import SwiftUI

fileprivate let viewHeight = 38.0
fileprivate let navigationAnimation = Animation.easeOut(duration: 0.25)

@resultBuilder enum CompBuilder {
    
    static func buildBlock(_ comps: [Comp]...) -> [Comp] {
        var result = [Comp]()
        for i in 0..<comps.count {
            for comp in comps[i] {
                result.append(comp.declarationID(i))
            }
        }
        return result
    }
    
    static func buildExpression(_ expression: Comp) -> [Comp] {
        [expression]
    }
    
    static func buildExpression(_ expression: Void) -> [Comp] {
        []
    }
    
    static func buildOptional(_ components: [Comp]?) -> [Comp] {
        components ?? []
    }
    
    static func buildEither(first components: [Comp]) -> [Comp] {
        components.map { $0.variationID(1) }
    }
    
    static func buildEither(second components: [Comp]) -> [Comp] {
        components.map { $0.variationID(2) }
    }
    
}

protocol CompProperty: RawRepresentable, CaseIterable, Displayable where Self.RawValue == Int {
}

protocol CompControllerProtocol: CompControllerBase {
    
    associatedtype Property: CompProperty
    
}

extension CompControllerProtocol {
    
    var activeProperty: Property? {
        get {
            .init(rawValue: self.activePropertyIndex)
        }
        set {
            self.activePropertyIndex = newValue?.rawValue
        }
    }
    
}

class CompControllerBase: ObservableObject, Equatable {
    
    let properties: [String]?
    @Published fileprivate(set) var activePropertyIndex: Int?
    private (set) var isActive = false
    private (set) var isDisclosed = false
    
    init(properties: [String]?, activePropertyIndex: Int?) {
        self.properties = properties
        self.activePropertyIndex = activePropertyIndex
    }
    
    init<P>(activeProperty: P) where P: CompProperty {
        self.properties = P.allCaseDisplayNames
        self.activePropertyIndex = activeProperty.rawValue
    }
    
    fileprivate func activate() {
        isActive = true
        onActive()
    }
    
    fileprivate func deactivate() {
        isActive = false
        onInactive()
    }
    
    fileprivate func disclose() {
        isDisclosed = true
        onDisclose()
    }
    
    fileprivate func close() {
        isDisclosed = false
        onClose()
    }
    
    func onVisible() { }
    
    func onInvisible() { }
    
    func onDisclose() { }
    
    func onClose() { }
    
    func onActive() { }
    
    func onInactive() { }
    
    func onActivePropertyWillChange() { }
    
    func onActivePropertyDidChange() { }
    
    static func == (lhs: CompControllerBase, rhs: CompControllerBase) -> Bool {
        lhs === rhs
    }
    
}

typealias CompController = CompControllerBase & CompControllerProtocol

struct Comp: Identifiable {
    
    let title: String
    private(set) var subtitle: String?
    fileprivate private(set) var subs: [Comp]
    
    fileprivate(set) var makeController: () -> CompControllerBase = { .init(properties: nil, activePropertyIndex: nil) }
    
    fileprivate private(set) var declarationID = IndexPath()
    fileprivate private(set) var variationID = IndexPath()
    
    init(_ title: String, subtitle: String? = nil, @CompBuilder _ builder: () -> [Comp]) {
        self.title = title
        self.subtitle = subtitle
        self.subs = builder()
    }
    
    init(_ title: String, subtitle: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.subs = []
    }
    
    var id: Int {
        var hasher = Hasher()
        hasher.combine(title)
        hasher.combine(subtitle)
        hasher.combine(declarationID)
        hasher.combine(variationID)
        return hasher.finalize()
    }
    
    func controller(_ controller: @escaping () -> CompControllerBase) -> Comp {
        var comp = self
        comp.makeController = controller
        return comp
    }
    
    func compAtIndexPath(_ indexPath: IndexPath) -> Comp? {
        guard let firstIndex = indexPath.first else {
            return self
        }
            
        guard firstIndex < subs.count else {
            return nil
        }
        
        return subs[firstIndex].compAtIndexPath(indexPath.dropFirst())
    }
    
    fileprivate init(_ title: String, subs: [Comp]) {
        self.title = title
        self.subs = subs
    }
    
    fileprivate func declarationID(_ id: Int) -> Comp {
        var comp = self
        comp.extendDeclarationID(id)
        return comp
    }
    
    private mutating func extendDeclarationID(_ id: Int) {
        self.declarationID.append(id)
        for index in self.subs.indices {
            self.subs[index].extendDeclarationID(id)
        }
    }
    
    fileprivate func variationID(_ id: Int) -> Comp {
        var comp = self
        comp.variationID.append(id)
        return comp
    }
    
}

fileprivate struct CompView<SCV>: View where SCV: View {
    
    let compId: Int
    let title: String
    let subtitle: String?
    let indexPath: IndexPath
    let subsView: SCV
    @Binding var activeIndexPath: IndexPath
    
    @StateObject fileprivate var controller: CompControllerBase
    @Namespace private var matchedGeometryEffectNamespace
    
    init(compId: Int, title: String, subtitle: String?, indexPath: IndexPath, activeIndexPath: Binding<IndexPath>, controllerProvider: @escaping () -> CompControllerBase, @ViewBuilder content: () -> SCV) {
        self.compId = compId
        self.title = title
        self.subtitle = subtitle
        self.indexPath = indexPath
        self.subsView = content()
        _activeIndexPath = activeIndexPath
        _controller = .init(wrappedValue: controllerProvider())
    }
    
    var body: some View {
        ZStack {
            compTextView()
                .preference(key: ActiveCompPropertyChangePreferenceKey.self, value: isActive && controller.activePropertyIndex != nil ? .init(compId: compId, controller: controller, activePropertyIndex: controller.activePropertyIndex!) : nil)
                .preference(key: DisclosedCompsPreferenceKey.self, value: isDisclosed ? [.init(compId: compId, title: title, subtitle: subtitle, indexPath: indexPath, controller: controller)] : [])
                
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                
                if let properties = controller.properties {
                    propertyViews(properties)
                }
                
                subsView
            }
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
        .onAppear {
            
            if isDisclosed {
                controller.disclose()
            }
            
            if isActive {
                controller.activate()
            }
        }
        .onDisappear {
            if isActive {
                controller.deactivate()
            }
            
            if isDisclosed {
                controller.close()
            }
        }
        .onChange(of: activeIndexPath) { [activeIndexPath] newValue in
            if activeIndexPath == indexPath {
                controller.deactivate()
            }
            
            if activeIndexPath.starts(with: indexPath) {
                if !newValue.starts(with: indexPath) {
                    controller.close()
                }
            } else {
                if newValue.starts(with: indexPath) {
                    controller.disclose()
                }
            }
            
            if newValue == indexPath {
                controller.activate()
            }
        }
    }
    
    private func compTextView() -> some View {
        textView(title)
            .overlay {
                VStack {
                    Spacer()
                    Image(systemName: "ellipsis")
                        .imageScale(.small)
                        .fontWeight(.light)
                        .foregroundColor(.primary)
                }
                .padding(.bottom, 1.0)
            }
            .scaleEffect(x: textHorizontalScale)
            .visible(isChildOfActive)
            .onTapGesture {
                withAnimation(navigationAnimation) {
                    activeIndexPath = indexPath
                }
            }
            .allowsHitTesting(isChildOfActive)
    }
    
    private func textView(_ title: String) -> some View {
        Text(title)
            .font(Font.system(size: 15, weight: .regular))
            .foregroundColor(.secondary)
            .fixedSize(horizontal: true, vertical: false)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.horizontal, isChildOfActive ? 8.0 : 0.0)
            .contentShape(Rectangle())
    }
    
    private var textHorizontalScale: CGFloat {
        guard let distance = distanceToActiveAncestor else { return 1.0 }
        return pow(1.3, 1.0 - CGFloat(distance))
    }
    
    private func propertyViews(_ properties: [String]) -> some View {
        ForEach(Array(properties.enumerated()), id: \.element, content: { index, property in
            textView(property)
                .background {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(.systemFill)
                        .visible(index == controller.activePropertyIndex)
                        .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: index == controller.activePropertyIndex)
                }
                .onTapGesture {
                    guard index != controller.activePropertyIndex else {
                        return
                    }
                    controller.onActivePropertyWillChange()
                    withAnimation(navigationAnimation) {
                        controller.activePropertyIndex = index
                    }
                    controller.onActivePropertyDidChange()
                }
            
        })
        .frame(maxWidth: isActive ? .infinity : 0.0)
        .visible(isActive)
        .allowsHitTesting(isActive)
    }
    
    private var isActive: Bool {
        indexPath == activeIndexPath
    }
    
    private var isChildOfActive: Bool {
        guard !indexPath.isEmpty else {
            return false
        }
        return indexPath.dropLast() == activeIndexPath
    }
    
    private var isDisclosed: Bool {
        activeIndexPath.starts(with: indexPath)
    }
    
    private var distanceToActiveAncestor: Int? {
        guard indexPath.starts(with: activeIndexPath) else {
            return nil
        }
        return indexPath.count - activeIndexPath.count
    }
    
}

struct CompTreeView<AV>: View where AV: View {
    
    @Binding var activeIndexPath: IndexPath
    let defaultActionView: (CompControllerBase) -> AV?
    
    private var rootView: AnyView
    @State private var disclosedCompsData: [DisclosedCompData]?
    
    init(activeIndexPath: Binding<IndexPath>, defaultActionView: @escaping (CompControllerBase) -> AV? = { _ in Optional<EmptyView>.none }, @CompBuilder builder: () -> [Comp]) {
        _activeIndexPath = activeIndexPath
        self.defaultActionView = defaultActionView
        
        var rootComp: Comp? = nil
        
        let comps = builder()
        switch comps.count {
        case 0:
            break
        case 1:
            rootComp = comps.first!
        default:
            rootComp = .init("<Root>", subs: comps)
        }
        
        if let rootComp = rootComp {
            rootView = Self.build(comp: rootComp, indexPath: .init(), activeIndexPath: _activeIndexPath)
        } else {
            rootView = AnyView(EmptyView())
        }
    }
    
    var body: some View { 
        VStack {
            if let activeCompData = activeCompData, let controller = activeCompData.controller {
                defaultActionView(controller)
            }
            
            rootView
                .padding(3.0)
                .frame(height: viewHeight)
                .background(Material.regular)
                .cornerRadius(SelectorConst.cornerRadius)
                .compositingGroup()
                .shadow(radius: 1.0)
        }
        .onPreferenceChange(DisclosedCompsPreferenceKey.self) { data in
            disclosedCompsData = data
        }
    }
    
    private var activeCompData: DisclosedCompData? {
        disclosedCompsData?.last
    }
    
    static func build(comp: Comp, indexPath: IndexPath, activeIndexPath: Binding<IndexPath>) -> AnyView {
        AnyView(CompView(compId: comp.id, title: comp.title, subtitle: comp.subtitle, indexPath: indexPath, activeIndexPath: activeIndexPath, controllerProvider: comp.makeController) {
            
            ForEach(Array(comp.subs.enumerated()), id: \.element.id) { index, subcomp in
                build(comp: subcomp, indexPath: indexPath.appending(index), activeIndexPath: activeIndexPath)
            }
            
        }
        .id(comp.id))
    }
}

struct DisclosedCompData: Equatable {
    
    let compId: Int
    let title: String
    let subtitle: String?
    let indexPath: IndexPath
    
    private(set) weak var controller: CompControllerBase?
    
    static func == (lhs: DisclosedCompData, rhs: DisclosedCompData) -> Bool {
        lhs.compId == rhs.compId
    }
}

struct DisclosedCompsPreferenceKey: PreferenceKey {
    static var defaultValue = [DisclosedCompData]()
    
    static func reduce(value: inout [DisclosedCompData], nextValue: () -> [DisclosedCompData]) {
        value.append(contentsOf: nextValue())
    }
}

struct ActiveCompPropertyChangePreferenceKey: PreferenceKey {
    
    struct Data: Equatable {
        let compId: Int
        private(set) weak var controller: CompControllerBase?
        let activePropertyIndex: Int
        
        static func == (lhs: Data, rhs: Data) -> Bool {
            lhs.compId == rhs.compId && lhs.activePropertyIndex == rhs.activePropertyIndex
        }
    }
    
    static var defaultValue: Data?
    
    static func reduce(value: inout Data?, nextValue: () -> Data?) {
        value = value ?? nextValue()
    }
}

struct CompTreeView_Previews: PreviewProvider {
    
    class DummyController: CompController {
        
        enum Property: Int, CompProperty {
            case a
            case b
            case c
        }
        
        convenience init() {
            self.init(activeProperty: Property.a)
        }
    }
    
    struct ContentView: View {
        
        @State var activeIndexPath = IndexPath()
        @State var toggleAAA = false
        @State var indicator = false
        @State var coordSystem = SPTCoordinateSystem.cartesian
        
        var body: some View {
            VStack {
                CompTreeView(activeIndexPath: $activeIndexPath, defaultActionView: { _ in
                    Color.red
                }) {
                    Comp("Human") {
                        Comp("Head")
                            .controller {
                                DummyController()
                            }
                        Comp("Belly")
                            .controller {
                                DummyController()
                            }
                    }
                    
                    Comp("Car") {
                        Comp("Frame")
                            .controller { DummyController() }
                        Comp("Motor")
                            .controller { DummyController() }
                    }
                    
                    if toggleAAA {
                        Comp("ToggleTrue")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    }
                    
                    if !toggleAAA {
                        Comp("ToggleFalse")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    }
                    
                    switch coordSystem {
                    case .cartesian:
                        Comp("Cartesian")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    case .linear:
                        Comp("Linear")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    case .cylindrical:
                        Comp("Cylindrical")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    case .spherical:
                        Comp("Spherical")
                            .controller {
                                indicator.toggle()
                                return DummyController()
                            }
                    }
                    
                }
                
                HStack() {
                    Button("Back") {
                        withAnimation {
                            _ = activeIndexPath.removeLast()
                        }
                    }
                    .disabled(activeIndexPath.isEmpty)
                    
                    Spacer()
                    
                    Button("Toggle") {
                        withAnimation {
                            toggleAAA.toggle()
                        }
                    }
                    
                    Spacer()
                    
                    Picker("Coordinate System", selection: $coordSystem) {
                        ForEach(SPTCoordinateSystem.allCases, id: \.self) { s in
                            Text(s.displayName)
                                .tag(s)
                        }
                    }
                }
                
                Toggle(isOn: $indicator, label: {
                    Text("Indicator")
                })
            }
            .padding()
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
