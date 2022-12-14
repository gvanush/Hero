//
//  ComponentTreeNavigationView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.09.22.
//

import SwiftUI


fileprivate let componentViewHeight = 38.0
fileprivate let defaultNavigationAnimation = Animation.easeOut(duration: 0.25)

struct ComponentTreeNavigationView<RC>: View where RC: Component {

    let rootComponent: RC
    @Binding var activeComponent: Component
    let viewProvider: ComponentViewProvider<RC>
    let setupViewProvider: ComponentSetupViewProvider
    @State private var inSetupComponent: Component?
    
    var body: some View {
        VStack(spacing: 8.0) {
            
            ActiveComponentViewContainer(component: activeComponent, rootComponent: rootComponent, viewProvider: viewProvider)
            
            ComponentSelectionView(component: rootComponent, activeComponent: $activeComponent, inSetupComponent: $inSetupComponent)
                .padding(3.0)
                .frame(height: componentViewHeight)
                .background(Material.regular)
                .cornerRadius(SelectorConst.cornerRadius)
                .compositingGroup()
                .shadow(radius: 1.0)
        }
        .sheet(item: $inSetupComponent) { component in
            component.accept(setupViewProvider) {
                if component.isSetup {
                    activeComponent = component
                }
                inSetupComponent = nil
            }
        }
        .onChange(of: activeComponent) { [activeComponent] newValue in
            activeComponent.deactivate()
            newValue.activate()
        }
        .onAppear {
            
            rootComponent.appear()
            
            let activeIndexPath = activeComponent.indexPathIn(rootComponent)!
            for i in 0...activeIndexPath.count {
                rootComponent.componentAt(activeIndexPath.prefix(i))!.disclose()
            }
            
            activeComponent.activate()
            
        }
        .onDisappear {
            activeComponent.deactivate()
            
            let activeIndexPath = activeComponent.indexPathIn(rootComponent)!
            for i in (0...activeIndexPath.count).reversed() {
                rootComponent.componentAt(activeIndexPath.prefix(i))!.close()
            }
            
            rootComponent.disappear()
        }
        
    }

}

fileprivate struct ActiveComponentViewContainer<RC>: View where RC: Component {
    
    @ObservedObject var component: Component
    let rootComponent: RC
    let viewProvider: ComponentViewProvider<RC>
    
    var body: some View {
        if rootComponent == component {
            viewProvider.viewForRoot(rootComponent)
        } else {
            component.accept(viewProvider)
        }
    }
}


fileprivate struct ComponentSelectionView: View {
    
    @ObservedObject var component: Component
    @Binding var activeComponent: Component
    @Binding var inSetupComponent: Component?
    
    @Namespace private var matchedGeometryEffectNamespace
    
    
    var body: some View {
        ZStack {
            textViewFor(component.title)
                .overlay {
                    VStack {
                        Spacer()
                        Image(systemName: component.isSetup ? "ellipsis" : "minus")
                            .imageScale(.small)
                            .fontWeight(.light)
                            .foregroundColor(.primary)
                    }
                    .padding(.bottom, component.isSetup ? 1.0 : 2.0)
                }
                .scaleEffect(x: textHorizontalScale)
                .visible(isChildOfActive)
                .onTapGesture {
                    withAnimation(defaultNavigationAnimation) {
                        if component.isSetup {
                            activeComponent = component
                        } else {
                            inSetupComponent = component
                        }
                    }
                }
                .allowsHitTesting(isChildOfActive)
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                
                if let properties = component.properties {
                    propertyViews(properties)
                }
                
                if let subcomponents = component.subcomponents {
                    ForEach(subcomponents) { subcomponent in
                        ComponentSelectionView(component: subcomponent, activeComponent: $activeComponent, inSetupComponent: $inSetupComponent)
                    }
                }
                
            }
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
        .onChange(of: component.isSetup, perform: { newValue in
            if isActive && !newValue {
                withAnimation(defaultNavigationAnimation) {
                    activeComponent = activeComponent.parent!
                }
            }
        })
        .onChange(of: isDisclosed) { newValue in
            // TODO: When active component is changed without to parent/children from the
            // current one onVisible is not called for root top node.
            // Perhaps the following logic must be moved to on active component changed callback
            if newValue {
                component.disclose()
            } else {
                component.close()
            }
        }
    }
    
    private var isActive: Bool {
        component == activeComponent
    }
    
    private var isChildOfActive: Bool {
        component.parent == activeComponent
    }
    
    private var isParentOfActive: Bool {
        activeComponent.parent == component
    }
    
    private var isRoot: Bool {
        component.parent == nil
    }
    
    private var isDisclosed: Bool {
        var nextAncestor: Component? = activeComponent
        while let ancestor = nextAncestor, ancestor != component {
            nextAncestor = ancestor.parent
        }
        return nextAncestor != nil
    }
    
    private var distanceToActiveAncestor: Int? {
        var distance = 0
        var nextAncestor: Component? = self.component
        while let ancestor = nextAncestor, ancestor != activeComponent {
            nextAncestor = ancestor.parent
            distance += 1
        }
        if nextAncestor != nil {
            return distance
        }
        return nil
    }
    
    private func propertyViews(_ properties: [String]) -> some View {
        ForEach(Array(properties.enumerated()), id: \.element, content: { index, property in
            textViewFor(property)
                .background {
                    RoundedRectangle(cornerRadius: .infinity)
                        .foregroundColor(.systemFill)
                        .visible(index == component.selectedPropertyIndex)
                        .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: index == component.selectedPropertyIndex)
                }
                .onTapGesture {
                    withAnimation(defaultNavigationAnimation) {
                        component.selectedPropertyIndex = index
                    }
                }
            
        })
        .frame(maxWidth: isActive ? .infinity : 0.0)
        .visible(isActive)
        .allowsHitTesting(isActive)
    }
    
    private func textViewFor(_ title: String) -> some View {
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
    
}


struct PropertyTreeNavigationVIew_Previews: PreviewProvider {
    
    class NamedComponent<P>: BasicComponent<P>
    where P: RawRepresentable & CaseIterable & Displayable, P.RawValue == Int {
    
        let name: String
        
        init(name: String, selectedProperty: P?, parent: Component?) {
            self.name = name
            super.init(selectedProperty: selectedProperty, parent: parent)
        }
        
        override var title: String {
            name
        }
        
    }
    
    class Root: Component {
        
        lazy var child1 = NamedComponent(name: "Child1", selectedProperty: Axis.x, parent: self)
        lazy var child2 = NamedComponent(name: "Child2", selectedProperty: Axis.x, parent: self)
        lazy var child3 = NamedComponent(name: "Child3", selectedProperty: Axis.x, parent: self)
        
        init() {
            super.init(parent: nil)
        }
        
        override var title: String {
            "Root"
        }
        
        override var subcomponents: [Component]? {
            [child1, child2, child3]
        }
        
    }
    
    class ContentViewModel: ObservableObject {
        
        let rootComponent = Root()
        @Published var activeComponent: Component
        
        init() {
            self.activeComponent = rootComponent
        }
        
    }
    
    struct ContentView: View {
        
        @StateObject private var model = ContentViewModel()
        
        var body: some View {
            ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: EmptyComponentViewProvider(), setupViewProvider: EmptyComponentSetupViewProvider())
                .padding()
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
