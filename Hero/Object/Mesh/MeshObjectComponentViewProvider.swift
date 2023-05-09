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
    
    override func viewFor(_ component: ObjectDistanceAnimatorBindingComponent) -> AnyView? {
        AnyView(DistanceAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: ObjectAngleAnimatorBindingComponent) -> AnyView? {
        AnyView(AngleAnimatorBindingComponentView(component: component))
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

    override func viewFor(_ component: CartesianPositionComponent) -> AnyView? {
        AnyView(CartesianPositionComponentView(component: component))
    }
    
    override func viewFor(_ component: XYZScaleFieldAnimatorBindingComponent) -> AnyView? {
        AnyView(XYZScaleFieldAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: UniformScaleFieldAnimatorBindingComponent) -> AnyView? {
        AnyView(UniformScaleFieldAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: EulerOrientationFieldAnimatorBindingComponent) -> AnyView? {
        AnyView(EulerOrientationFieldAnimatorBindingComponentView(component: component))
    }
}

