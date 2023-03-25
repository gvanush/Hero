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
    
    init(properties: [String]?, activePropertyIndex: Int?) {
        self.properties = properties
        self.activePropertyIndex = activePropertyIndex
    }
    
    convenience init<P>(activeProperty: P) where P: CompProperty {
        self.init(properties: P.allCaseDisplayNames, activePropertyIndex: activeProperty.rawValue)
    }
    
    fileprivate func activate() {
        isActive = true
        onActive()
    }
    
    fileprivate func deactivate() {
        isActive = false
        onInactive()
    }
    
    func onAwake() { }
    
    func onSleep() { }
    
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
    
    fileprivate let title: String
    fileprivate private(set) var subs: [Comp]
    fileprivate private(set) var makeController: () -> CompControllerBase = { .init(properties: nil, activePropertyIndex: nil) }
    fileprivate private(set) var actionView: (CompControllerBase) -> AnyView? = { _ in nil }
    fileprivate private(set) var optionsView: (CompControllerBase) -> AnyView? = { _ in nil }
    
    private(set) var indexPath: IndexPath!
    
    fileprivate private(set) var declarationID = IndexPath()
    fileprivate private(set) var variationID = IndexPath()
    
    init(_ title: String, @CompBuilder _ builder: () -> [Comp]) {
        self.title = title
        self.subs = builder()
    }
    
    init(_ title: String) {
        self.title = title
        self.subs = []
    }
    
    var id: Int {
        var hasher = Hasher()
        hasher.combine(declarationID)
        hasher.combine(variationID)
        return hasher.finalize()
    }
    
    func controller(_ controller: @escaping () -> CompControllerBase) -> Comp {
        var comp = self
        comp.makeController = controller
        return comp
    }
    
    func actionView(_ view: @escaping (CompControllerBase) -> some View) -> Comp {
        var comp = self
        comp.actionView = { AnyView(view($0)) }
        return comp
    }
    
    func optionsView(_ view: @escaping (CompControllerBase) -> some View) -> Comp {
        var comp = self
        comp.optionsView = { AnyView(view($0)) }
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
    
    fileprivate mutating func updateIndexPath(_ indexPath: IndexPath) {
        self.indexPath = indexPath
        for i in 0..<subs.count {
            subs[i].updateIndexPath(indexPath.appending(i))
        }
    }
    
}

fileprivate struct CompView: View {
    
    let comp: Comp
    @Binding var activeIndexPath: IndexPath
    
    @StateObject fileprivate var controller: CompControllerBase
    @Namespace private var matchedGeometryEffectNamespace
    
    init(comp: Comp, activeIndexPath: Binding<IndexPath>) {
        self.comp = comp
        _activeIndexPath = activeIndexPath
        _controller = .init(wrappedValue: comp.makeController())
    }
    
    var body: some View {
        ZStack {
            compTextView()
                .preference(key: ActiveCompPreferenceKey.self, value: isActive ? .init(comp: comp, controller: controller) : nil)
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                
                if let properties = controller.properties {
                    propertyViews(properties)
                }
                
                ForEach(comp.subs, id: \.id) { subcomp in
                    CompView(comp: subcomp, activeIndexPath: $activeIndexPath)
                }
            }
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
        .onAppear {
            if isActive {
                controller.activate()
            }
        }
        .onDisappear {
            if isActive {
                controller.deactivate()
            }
        }
        .onChange(of: activeIndexPath) { [activeIndexPath] newValue in
            if activeIndexPath == comp.indexPath {
                controller.deactivate()
            }
            if newValue == comp.indexPath {
                controller.activate()
            }
        }
        
    }
    
    private func compTextView() -> some View {
        textView(comp.title)
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
                    activeIndexPath = comp.indexPath
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
                    withAnimation(navigationAnimation) {
                        controller.onActivePropertyWillChange()
                        controller.activePropertyIndex = index
                        controller.onActivePropertyDidChange()
                    }
                }
            
        })
        .frame(maxWidth: isActive ? .infinity : 0.0)
        .visible(isActive)
        .allowsHitTesting(isActive)
    }
    
    private var isActive: Bool {
        comp.indexPath == activeIndexPath
    }
    
    private var isChildOfActive: Bool {
        guard !comp.indexPath.isEmpty else {
            return false
        }
        return comp.indexPath.dropLast() == activeIndexPath
    }
    
    private var isDisclosed: Bool {
        activeIndexPath.starts(with: comp.indexPath)
    }
    
    private var distanceToActiveAncestor: Int? {
        guard comp.indexPath.starts(with: activeIndexPath) else {
            return nil
        }
        return comp.indexPath.count - activeIndexPath.count
    }
    
}

struct CompTreeView<CV>: View where CV: View {
    
    @Binding var activeIndexPath: IndexPath
    let defaultActionView: (CompControllerBase) -> CV?
    
    private let rootView: CompView
    @State private var activeCompData: ActiveCompData?
    
    init(activeIndexPath: Binding<IndexPath>, defaultActionView: @escaping (CompControllerBase) -> CV? = { _ in Optional<EmptyView>.none }, @CompBuilder builder: () -> [Comp]) {
        _activeIndexPath = activeIndexPath
        self.defaultActionView = defaultActionView
        
        let comps = builder()
        var rootComp: Comp!
        if comps.count == 1 {
            rootComp = comps.first!
        } else {
            rootComp = .init("<Root>", subs: comps)
        }
        rootComp.updateIndexPath(.init())
        rootView = .init(comp: rootComp, activeIndexPath: activeIndexPath)
    }
    
    var body: some View { 
        VStack {
            if let activeCompData = activeCompData {
                if let view = activeCompData.comp.actionView(activeCompData.controller) {
                    view
                } else {
                    defaultActionView(activeCompData.controller)
                }
            }
            
            rootView
                .padding(3.0)
                .frame(height: viewHeight)
                .background(Material.regular)
                .cornerRadius(SelectorConst.cornerRadius)
                .compositingGroup()
                .shadow(radius: 1.0)
                .id(rootView.comp.id)
        }
        .onPreferenceChange(ActiveCompPreferenceKey.self) { data in
            self.activeCompData = data
        }
        .onAppear {
            // Adjust active to valid ancestor
            while activeIndexPath.count > 0 && rootView.comp.compAtIndexPath(activeIndexPath) == nil {
                activeIndexPath.removeLast()
            }
        }
    }
    
}

fileprivate struct ActiveCompData: Equatable {
    let comp: Comp
    let controller: CompControllerBase
    
    static func == (lhs: ActiveCompData, rhs: ActiveCompData) -> Bool {
        // TODO
        lhs.controller == rhs.controller
    }
}

fileprivate struct ActiveCompPreferenceKey: PreferenceKey {
    static var defaultValue: ActiveCompData? { nil }
    
    static func reduce(value: inout ActiveCompData?, nextValue: () -> ActiveCompData?) {
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
                            .actionView { _ in
                                AnyView(Color.green)
                            }
                        Comp("Belly")
                            .controller {
                                DummyController()
                            }
                            .actionView { _ in
                                AnyView(Color.blue)
                            }
                    }
                    .actionView { _ in
                        AnyView(Color.cyan)
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
