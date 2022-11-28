//
//  MeshObjectComponentViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI


class MeshObjectComponentViewProvider<RC>: ComponentViewProvider<RC> {
    
    override func viewFor<AnimatorBindingComponent>(_ component: AnimatorBindingSetupComponent<AnimatorBindingComponent>) -> AnyView? {
        AnyView(AnimatorBindingSetupComponentView<AnimatorBindingComponent, RC>(component: component, provider: self))
    }
    
    override func viewFor(_ component: PositionFieldAnimatorBindingComponent) -> AnyView? {
        AnyView(PositionFieldAnimatorBindingView(component: component))
    }
    
    override func viewFor(_ component: ShininessAnimatorBindingComponent) -> AnyView? {
        AnyView(ShininessAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor<C>(_ component: ObjectColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectColorComponentView(component: component, viewProvider: self))
    }
    
    override func viewFor<C>(_ component: ObjectRGBAColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectRGBAColorComponentView(component: component))
    }
    
    override func viewFor<C>(_ component: ObjectHSBAColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectHSBAColorComponentView(component: component))
    }
    
    override func viewFor(_ component: ObjectRGBAColorChannelAnimatorBindingComponent) -> AnyView? {
        AnyView(ObjectRGBAColorChannelAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: ObjectHSBAColorChannelAnimatorBindingComponent) -> AnyView? {
        AnyView(ObjectHSBAColorChannelAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: PositionComponent) -> AnyView? {
        AnyView(PositionComponentView(component: component, viewProvider: self))
    }

    override func viewFor(_ component: CartesianPositionComponent) -> AnyView? {
        AnyView(CartesianPositionComponentView(component: component))
    }
    
    override func viewFor(_ component: LinearPositionComponent) -> AnyView? {
        AnyView(LinearPositionComponentView(component: component))
    }
    
    override func viewFor(_ component: CylindricalPositionComponent) -> AnyView? {
        AnyView(CylindricalPositionComponentView(component: component))
    }
}

