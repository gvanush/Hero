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
    
    var body: some View {
        VStack(spacing: 0.0) {
            ComponentView(component: rootComponent, activeComponent: $activeComponent)
            .padding(3.0)
            .frame(maxHeight: Self.componentViewHeight)
            .background(Material.bar)
            .compositingGroup()
            .shadow(radius: 0.5)
            
            BottomBar()
                .overlay {
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
                    .padding(.horizontal, 8.0)
                }
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
                HStack() {}
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
 
    static let componentViewHeight = 40.0
    static let height = componentViewHeight + BottomBar.height
}


fileprivate struct ComponentView: View {
    
    @ObservedObject var component: Component
    @Binding var activeComponent: Component
    @Namespace private var matchedGeometryEffectNamespace
    
    
    var body: some View {
        ZStack {
            textViewFor(component.title)
                .overlay {
                    VStack {
                        Spacer()
                        Image(systemName: "ellipsis")
                            .foregroundColor(.accentColor)
                    }
                    .padding(.bottom, 2.0)
                }
                .scaleEffect(textScale)
                .visible(isChildOfActive)
                .onTapGesture {
                    withAnimation(navigationAnimation) {
                        activeComponent = component
                    }
                }
                .allowsHitTesting(isChildOfActive)
            
            HStack(spacing: isChildOfActive ? 4.0 : 0.0) {
                
                if let properties = component.properties {
                    propertyViews(properties)
                }
                
                if let subcomponents = component.subcomponents {
                    ForEach(subcomponents) { subcomponent in
                        ComponentView(component: subcomponent, activeComponent: $activeComponent)
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
                        .visible(index == component.activePropertyIndex)
                        .matchedGeometryEffect(id: "Selected", in: matchedGeometryEffectNamespace, isSource: index == component.activePropertyIndex)
                }
                .onTapGesture {
                    withAnimation(navigationAnimation) {
                        component.activePropertyIndex = index
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
    
    struct ContainerView: View {
        
        @StateObject var transformation: TransformationComponent
        @State var active: Component
        
        init() {
            let transformation = TransformationComponent(object: kSPTNullObject, parent: nil)
            _transformation = StateObject(wrappedValue: transformation)
            _active = State(initialValue: transformation)
        }
        
        var body: some View {
            ComponentTreeNavigationView(rootComponent: transformation, activeComponent: $active)
        }
    }
    
    static var previews: some View {
        ContainerView()
    }
}
