//
//  PropertyTreeNavigationView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.01.22.
//

import SwiftUI

fileprivate let navigationAnimation = Animation.easeOut(duration: 0.25)


struct ComponentTreeNavigationView: View {

    let rootComponent: Component
    @Binding var activeComponent: Component
    let setupViewProvider: ComponentSetupViewProvider
    @State private var inSetupComponent: Component?
    
    var body: some View {
        VStack(spacing: 8.0) {
            ComponentView(component: rootComponent, activeComponent: $activeComponent, inSetupComponent: $inSetupComponent)
                .padding(3.0)
                .overlay {
                    RoundedRectangle(cornerRadius: .infinity)
                        .stroke(Color.secondaryLabel, lineWidth: 1.0)
                        .shadow(radius: 0.5)
                }
                .frame(height: Self.componentViewHeight)
            
            HStack {
                backButton
                
                Text(activeComponent.title)
                    .font(Font.system(size: 15, weight: .semibold))
                    .lineLimit(1)
                    .transition(.identity)
                    .id(activeComponent.title)
                    .layoutPriority(1.0)
                    
                editComponentButton
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .padding(8.0)
        .frame(maxWidth: .infinity, maxHeight: Self.height)
        .background(Material.bar)
        .compositingGroup()
        .shadow(radius: 0.5)
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
    
    var backButton: some View {
        Group {
            if let parent = activeComponent.parent {
                Button {
                    withAnimation(navigationAnimation) {
                        activeComponent = parent
                    }
                } label: {
                    HStack(spacing: 0.0) {
                        Image(systemName: "chevron.left")
                            .font(Font.system(size: 21, weight: .medium))
                        Text(parent.title)
                            .font(Font.system(size: 15, weight: .regular))
                            .lineLimit(1)
                            .transition(.identity)
                            .id(parent.title)
                    }
                }
            } else {
                HStack {}
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
 
    var editComponentButton: some View {
        Button {
            // TODO:
        } label: {
            Image(systemName: "pencil.circle")
                .imageScale(.large)
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .hidden() // TODO
    }
 
    static let componentViewHeight = 34.0
    static let height = componentViewHeight + 57.0
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
                            .foregroundColor(component.isSetup ? .accentColor : .lightAccentColor)
                    }
                    .padding(.bottom, component.isSetup ? 1.0 : 2.0)
                }
                .scaleEffect(textScale)
                .visible(isChildOfActive)
                .onTapGesture {
                    withAnimation(navigationAnimation) {
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
                    withAnimation(navigationAnimation) {
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
    
    private var textScale: CGFloat {
        guard let distance = distanceToActiveAncestor else { return 1.0 }
        return pow(1.3, 1.0 - CGFloat(distance))
    }
    
}


struct ComponentTreeNavigationView_Previews: PreviewProvider {
    
    static let sceneViewModel = SceneViewModel()
    
    struct ContainerView: View {
        
        @StateObject var transformation: TransformationComponent
        @State var active: Component
        
        init() {
            let transformation = TransformationComponent(object: kSPTNullObject, sceneViewModel: sceneViewModel, parent: nil)
            _transformation = StateObject(wrappedValue: transformation)
            _active = State(initialValue: transformation)
        }
        
        var body: some View {
            ComponentTreeNavigationView(rootComponent: transformation, activeComponent: $active, setupViewProvider: CommonComponentSetupViewProvider())
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
