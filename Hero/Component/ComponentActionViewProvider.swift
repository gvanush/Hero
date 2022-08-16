//
//  ComponentActionViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.02.22.
//

import Foundation
import SwiftUI


protocol ComponentActionViewProvider {
    
    func viewFor(_ component: BasePositionComponent) -> AnyView?
    func viewFor(_ component: OrientationComponent) -> AnyView?
    func viewFor(_ component: ScaleComponent) -> AnyView?
    func viewFor(_ component: TransformationComponent) -> AnyView?
    func viewFor(_ component: ArrangementComponent) -> AnyView?
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty
    func viewFor(_ component: GeneratorComponent) -> AnyView?
    func viewFor(_ component: MeshObjectComponent) -> AnyView?
    
}


extension ComponentActionViewProvider {
    
    func viewFor(_ component: BasePositionComponent) -> AnyView? { nil }
    func viewFor(_ component: OrientationComponent) -> AnyView? { nil }
    func viewFor(_ component: ScaleComponent) -> AnyView? { nil }
    func viewFor(_ component: TransformationComponent) -> AnyView? { nil }
    func viewFor(_ component: ArrangementComponent) -> AnyView? { nil }
    func viewFor<AP>(_ component: AnimatorBindingComponent<AP>) -> AnyView? where AP: SPTAnimatableProperty { nil }
    func viewFor(_ component: GeneratorComponent) -> AnyView? { nil }
    func viewFor(_ component: MeshObjectComponent) -> AnyView? { nil }
    
}


struct GeneratorComponentActionViewProvider: ComponentActionViewProvider {
    
    func viewFor(_ component: BasePositionComponent) -> AnyView? {
        AnyView(EditBasePositionComponentView(component: component))
    }
    
    func viewFor(_ component: OrientationComponent) -> AnyView? {
        AnyView(EditOrientationComponentView(component: component))
    }
    
    func viewFor(_ component: ScaleComponent) -> AnyView? {
        AnyView(EditScaleComponentView(component: component))
    }
    
    func viewFor(_ component: ArrangementComponent) -> AnyView? {
        AnyView(EditArrangementComponentView(component: component))
    }
    
    func viewFor(_ component: GeneratorComponent) -> AnyView? {
        AnyView(EditGeneratorComponentView(component: component))
    }
}
