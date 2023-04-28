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
    
    override func viewFor<C>(_ component: ObjectColorComponent<C>) -> AnyView? where C: SPTInspectableComponent {
        AnyView(ObjectColorComponentView(component: component, viewProvider: self))
    }
    
    override func viewFor<C>(_ component: ObjectRGBAColorComponent<C>) -> AnyView? where C: SPTInspectableComponent {
        AnyView(ObjectRGBAColorComponentView(component: component))
    }
    
    override func viewFor<C>(_ component: ObjectHSBAColorComponent<C>) -> AnyView? where C: SPTInspectableComponent {
        AnyView(ObjectHSBAColorComponentView(component: component))
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
    
    override func viewFor(_ component: XYZScaleComponent) -> AnyView? {
        AnyView(XYZScaleComponentView(component: component))
    }
    
    override func viewFor(_ component: UniformScaleComponent) -> AnyView? {
        AnyView(UniformScaleComponentView(component: component))
    }
    
    override func viewFor(_ component: XYZScaleFieldAnimatorBindingComponent) -> AnyView? {
        AnyView(XYZScaleFieldAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: UniformScaleFieldAnimatorBindingComponent) -> AnyView? {
        AnyView(UniformScaleFieldAnimatorBindingComponentView(component: component))
    }
    
    override func viewFor(_ component: EulerOrientationComponent) -> AnyView? {
        AnyView(EulerOrientationComponentView(component: component))
    }
    
    override func viewFor(_ component: PointAtDirectionComponent) -> AnyView? {
        AnyView(PointAtDirectionComponentView(component: component))
    }
    
    override func viewFor(_ component: EulerOrientationFieldAnimatorBindingComponent) -> AnyView? {
        AnyView(EulerOrientationFieldAnimatorBindingComponentView(component: component))
    }
}

