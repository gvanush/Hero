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
        AnyView(ShininessAnimatorBindingView(component: component))
    }
    
    override func viewFor<C>(_ component: ObjectColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectColorView(component: component, viewProvider: self))
    }
    
    override func viewFor<C>(_ component: ObjectRGBAColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectRGBAColorComponentView(component: component))
    }
    
    override func viewFor<C>(_ component: ObjectHSBAColorComponent<C>) -> AnyView? where C: SPTObservableComponent {
        AnyView(ObjectHSBAColorComponentView(component: component))
    }

}

