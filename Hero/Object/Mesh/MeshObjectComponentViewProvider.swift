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
    
    override func viewFor(_ component: ShininessAnimatorBindingComponent) -> AnyView? {
        AnyView(ShininessAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: ObjectRGBAColorChannelAnimatorBindingComponent) -> AnyView? {
        AnyView(ObjectRGBAColorChannelAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: ObjectHSBAColorChannelAnimatorBindingComponent) -> AnyView? {
        AnyView(ObjectHSBAColorChannelAnimatorBindingComponentView(component: component))
    }
    
}

