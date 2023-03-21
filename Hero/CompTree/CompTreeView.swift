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
        comps.flatMap { $0 }
    }
    
    static func buildExpression(_ expression: Comp) -> [Comp] {
        [expression]
    }
    
    static func buildExpression(_ expression: Void) -> [Comp] {
        []
    }
    
    static func buildOptional(_ component: [Comp]?) -> [Comp] {
        component ?? []
    }
    
    static func buildEither(first component: [Comp]) -> [Comp] {
        component
    }
    
    static func buildEither(second component: [Comp]) -> [Comp] {
        component
    }
    
}

protocol CompControllerProtocol: CompControllerBase {
    
    associatedtype Property: RawRepresentable, CaseIterable, Displayable where Property.RawValue == Int
    
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
    
    private (set) var isActive = false
    @Published fileprivate(set) var activePropertyIndex: Int?
    
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

struct Comp {
    
    fileprivate let title: String
    fileprivate let subs: [Comp]
    fileprivate let makeController: () -> CompControllerBase?
    fileprivate let properties: [String]?
    fileprivate private(set) var actionView: (CompControllerBase) -> AnyView? = { _ in nil }
    
    init<C>(_ title: String, controller: @escaping () -> C, @CompBuilder builder: () -> [Comp])  where C: CompController {
        self.title = title
        self.subs = builder()
        self.makeController = controller
        self.properties = C.Property.allCaseDisplayNames
    }
    
    init(_ title: String, @CompBuilder builder: () -> [Comp]) {
        self.title = title
        self.subs = builder()
        self.makeController = { nil }
        self.properties = nil
    }
    
    init<C>(_ title: String, controller: @escaping () -> C) where C: CompController {
        self.title = title
        self.subs = []
        self.makeController = controller
        self.properties = C.Property.allCaseDisplayNames
    }
    
    fileprivate init(_ title: String, subs: [Comp]) {
        self.title = title
        self.subs = subs
        self.makeController = { nil }
        self.properties = nil
    }
    
    func actionView(_ view: @escaping (CompControllerBase) -> AnyView?) -> Comp {
        var comp = self
        comp.actionView = view
        return comp
    }
}

fileprivate struct CompView: View {
    
    let title: String
    let properties: [String]?
    let indexPath: IndexPath
    @Binding var activeIndexPath: IndexPath
    let subviews: [CompView]
    let actionView: (CompControllerBase) -> AnyView?
    
    @StateObject fileprivate var controller: CompControllerBase
    @Namespace private var matchedGeometryEffectNamespace
    
    init(comp: Comp, indexPath: IndexPath, activeIndexPath: Binding<IndexPath>, subviews: [CompView]) {
        
        self.title = comp.title
        self.properties = comp.properties
        self.actionView = comp.actionView
        self.indexPath = indexPath
        _activeIndexPath = activeIndexPath
        self.subviews = subviews
        
        if let c = comp.makeController() {
            _controller = .init(wrappedValue: c)
        } else {
            _controller = .init(wrappedValue: .init())
        }
        
    }
    
    var body: some View {
        ZStack {
            compTextView()
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                
                if let properties = properties {
                    propertyViews(properties)
                }
                
                ForEach(subviews, id: \.indexPath) { subview in
                    subview
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
            if activeIndexPath == indexPath {
                controller.deactivate()
            }
            if newValue == indexPath {
                controller.activate()
            }
        }
        .preference(key: ActiveControllerPreferenceKey.self, value: isActive ? controller : nil)
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
    
    func viewAt(_ indexPath: IndexPath) -> CompView {
        guard !indexPath.isEmpty else {
            return self
        }
        return subviews[indexPath.first!].viewAt(indexPath.dropFirst())
    }
}

struct CompTreeView<CV>: View where CV: View {
    
    @Binding var activeIndexPath: IndexPath
    let defaultActionView: (CompControllerBase) -> CV?
    
    private let rootView: CompView
    @State private var activeController: CompControllerBase?
    
    init(activeIndexPath: Binding<IndexPath>, defaultActionView: @escaping (CompControllerBase) -> CV? = { _ in Optional<EmptyView>.none }, @CompBuilder builder: () -> [Comp]) {
        _activeIndexPath = activeIndexPath
        self.defaultActionView = defaultActionView
        
        let result = builder()
        if result.count == 1 {
            rootView = Self.buildRootView(result.first!, indexPath: .init(), activeIndexPath: activeIndexPath)
        } else {
            rootView = Self.buildRootView(.init("<Root>", subs: result), indexPath: .init(), activeIndexPath: activeIndexPath)
        }
    }
    
    var body: some View { 
        VStack {
            if let activeController = activeController {
                if let view = rootView.viewAt(activeIndexPath).actionView(activeController) {
                    view
                } else {
                    defaultActionView(activeController)
                }
            }
            
            rootView
                .padding(3.0)
                .frame(height: viewHeight)
                .background(Material.regular)
                .cornerRadius(SelectorConst.cornerRadius)
                .compositingGroup()
                .shadow(radius: 1.0)
        }
        .onPreferenceChange(ActiveControllerPreferenceKey.self) { controller in
            self.activeController = controller
        }
    }
    
    fileprivate static func buildRootView(_ comp: Comp, indexPath: IndexPath, activeIndexPath: Binding<IndexPath>) -> CompView {
        
        .init(comp: comp, indexPath: indexPath, activeIndexPath: activeIndexPath, subviews: {
            var subviews = [CompView]()
            for i in 0..<comp.subs.count {
                subviews.append(buildRootView(comp.subs[i], indexPath: indexPath.appending(i), activeIndexPath: activeIndexPath))
            }
            return subviews
        }())
        
    }
}

fileprivate struct ActiveControllerPreferenceKey: PreferenceKey {
    static var defaultValue: CompControllerBase? { nil }
    
    static func reduce(value: inout CompControllerBase?, nextValue: () -> CompControllerBase?) {
        value = value ?? nextValue()
    }
}


struct CompTreeView_Previews: PreviewProvider {
    
    class DummyController: CompController {
        
        enum Property: Int, RawRepresentable, CaseIterable, Displayable {
            case a
            case b
            case c
        }
        
        var activeProperty = Property.a
    }
    
    struct ContentView: View {
        
        @State var activeIndexPath = IndexPath()
        @State var toggleAAA = false
        @State var coordSystem = SPTCoordinateSystem.cartesian
        
        var body: some View {
            VStack {
                CompTreeView(activeIndexPath: $activeIndexPath, defaultActionView: { _ in
                    Color.red
                }) {
                    Comp("Human") {
                        Comp("Head", controller: { DummyController() }).actionView { _ in
                            AnyView(Color.green)
                        }
                        Comp("Belly") { DummyController() }.actionView { _ in
                            AnyView(Color.blue)
                        }
                    }
                    Comp("Car") {
                        Comp("Frame") { DummyController() }
                        Comp("Motor") { DummyController() }
                    }
                    
                    switch coordSystem {
                    case .cartesian:
                        Comp("Cartesian") { DummyController() }
                    case .linear:
                        Comp("Linear")  { DummyController() }
                    case .cylindrical:
                        Comp("Cylindrical")  { DummyController() }
                    case .spherical:
                        Comp("Spherical")  { DummyController() }
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
                    
                    Picker("Coordinate System", selection: $coordSystem) {
                        ForEach(SPTCoordinateSystem.allCases, id: \.self) { s in
                            Text(s.displayName)
                                .tag(s)
                        }
                    }
                }
            }
            .padding()
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
