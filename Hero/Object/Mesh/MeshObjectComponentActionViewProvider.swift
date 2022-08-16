//
//  MeshObjectComponentActionViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI


struct MeshObjectComponentActionViewProvider: ComponentActionViewProvider {
    
    func viewFor(_ component: BasePositionComponent) -> AnyView? {
        AnyView(EditBasePositionComponentView(component: component))
    }
    
    func viewFor(_ component: OrientationComponent) -> AnyView? {
        AnyView(EditOrientationComponentView(component: component))
    }
    
    func viewFor(_ component: ScaleComponent) -> AnyView? {
        AnyView(EditScaleComponentView(component: component))
    }
    
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty {
        AnyView(EditAnimatorBindingComponentView(component: component))
    }

}

