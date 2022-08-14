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
    
    func viewFor(_ component: AnimatorBindingComponent) -> AnyView? {
        AnyView(EditAnimatorBindingComponentView(component: component))
    }
}

