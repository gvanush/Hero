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
    
    func viewFor<AnimatorBindingComponent>(_ component: AnimatorBindingSetupComponent<AnimatorBindingComponent>) -> AnyView? { nil }
    
    func viewFor(_ component: ShininessAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: ObjectRGBAColorChannelAnimatorBindingComponent) -> AnyView? { nil }
    
    func viewFor(_ component: ObjectHSBAColorChannelAnimatorBindingComponent) -> AnyView? { nil }
    
}

final class EmptyComponentViewProvider<RC>: ComponentViewProvider<RC> {
    
}
