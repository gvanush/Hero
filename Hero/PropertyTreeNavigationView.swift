//
//  PropertyTreeNavigationView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.09.22.
//

import SwiftUI


struct PropertyTreeNavigationVIew: View {

    let rootComponent: Component
    @Binding var activeComponent: Component
    let actionViewViewProvider: ComponentActionViewProvider
    let setupViewProvider: ComponentSetupViewProvider
    @State private var inSetupComponent: Component?
    
    var body: some View {
        VStack(spacing: 8.0) {
            
            activeComponent.accept(actionViewViewProvider)
            
            ComponentView(component: rootComponent, activeComponent: $activeComponent, inSetupComponent: $inSetupComponent)
                .padding(3.0)
                .frame(height: Self.componentViewHeight)
                .background(Material.thin)
                .cornerRadius(SelectorConst.cornerRadius)
        }
        .compositingGroup()
        .shadow(radius: 1.0)
        .sheet(item: $inSetupComponent) { component in
            component.accept(setupViewProvider) {
                if component.isSetup {
                    activeComponent = component
                }
                inSetupComponent = nil
            }
        }
        .onChange(of: activeComponent) { [activeComponent] newValue in
            activeComponent.onInactive()
            newValue.onActive()
        }
        .onAppear {
            activeComponent.onActive()
        }
        .onDisappear {
            activeComponent.onInactive()
        }
        
    }
 
    static let componentViewHeight = 38.0
    static let defaultNavigationAnimation = Animation.easeOut(duration: 0.25)
}


fileprivate struct ComponentView: View {
    
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
                    withAnimation(PropertyTreeNavigationVIew.defaultNavigationAnimation) {
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
                        ComponentView(component: subcomponent, activeComponent: $activeComponent, inSetupComponent: $inSetupComponent)
                    }
                }
                
            }
        }
        .frame(maxWidth: isDisclosed || isChildOfActive ? .infinity : 0.0)
        .visible(isDisclosed || isChildOfActive)
        .onChange(of: component.isSetup, perform: { newValue in
            if isActive && !newValue {
                withAnimation(PropertyTreeNavigationVIew.defaultNavigationAnimation) {
                    activeComponent = activeComponent.parent!
                }
            }
        })
    }
    
    private var isActive: Bool {
        component === activeComponent
    }
    
    private var isChildOfActive: Bool {
        component.parent === activeComponent
    }
    
    private var isParentOfActive: Bool {
        activeComponent.parent === component
    }
    
    private var isRoot: Bool {
        component.parent == nil
    }
    
    private var isDisclosed: Bool {
        var nextAncestor: Component? = activeComponent
        while let ancestor = nextAncestor, ancestor !== component {
            nextAncestor = ancestor.parent
        }
        return nextAncestor != nil
    }
    
    private var isDescendantOfActive: Bool {
        var nextAncestor: Component? = self.component.parent
        while let ancestor = nextAncestor, ancestor !== activeComponent {
            nextAncestor = ancestor.parent
        }
        return nextAncestor === activeComponent
    }
    
    private var distanceToActiveAncestor: Int? {
        var distance = 0
        var nextAncestor: Component? = self.component
        while let ancestor = nextAncestor, ancestor !== activeComponent {
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
                    withAnimation(PropertyTreeNavigationVIew.defaultNavigationAnimation) {
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
    
    class Root: Component {
        
        lazy var child1 = BasicComponent(title: "Child1", selectedProperty: Axis.x, parent: self)
        lazy var child2 = BasicComponent(title: "Child2", selectedProperty: Axis.x, parent: self)
        lazy var child3 = BasicComponent(title: "Child3", selectedProperty: Axis.x, parent: self)
        
        init() {
            super.init(title: "Root", parent: nil)
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
            PropertyTreeNavigationVIew(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, actionViewViewProvider: EmptyComponentActionViewProvider(), setupViewProvider: EmptyComponentSetupViewProvider())
                .padding()
        }
        
    }
    
    static var previews: some View {
        ContentView()
    }
}
