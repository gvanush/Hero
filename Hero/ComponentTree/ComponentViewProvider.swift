//
//  ComponentViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.02.22.
//

import Foundation
import SwiftUI


class ComponentViewProvider<RC> {
    
    func viewForRoot(_ root: RC) -> AnyView? { nil }
    
    func viewFor<C>(_ component: ObjectColorComponent<C>) -> AnyView? where C: SPTInspectableComponent { nil }
    
    func viewFor<C>(_ component: ObjectRGBAColorComponent<C>) -> AnyView? where C: SPTInspectableComponent { nil }
    
    func viewFor<C>(_ component: ObjectHSBAColorComponent<C>) -> AnyView? where C: SPTInspectableComponent { nil }
    
    func viewFor<AnimatorBindingComponent>(_ component: AnimatorBindingSetupComponent<AnimatorBindingComponent>) -> AnyView? { nil }
    
    func viewFor(_ component: ObjectDistanceAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: ObjectAngleAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: ShininessAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: ObjectRGBAColorChannelAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: ObjectHSBAColorChannelAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: CartesianPositionComponent) -> AnyView? { nil }
    
    func viewFor(_ component: XYZScaleFieldAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: UniformScaleFieldAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: EulerOrientationFieldAnimatorBindingComponent) -> AnyView? {
        nil
    }
}

final class EmptyComponentViewProvider<RC>: ComponentViewProvider<RC> {
    
}
