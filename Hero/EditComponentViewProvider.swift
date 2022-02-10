//
//  EditComponentViewProvider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.02.22.
//

import Foundation
import SwiftUI


protocol EditComponentViewProvider {
    
    func viewFor(_ component: PositionComponent) -> AnyView?
    func viewFor(_ component: OrientationComponent) -> AnyView?
    func viewFor(_ component: ScaleComponent) -> AnyView?
    func viewFor(_ component: TransformationComponent) -> AnyView?
    func viewFor(_ component: GeneratorComponent) -> AnyView?
    
}


extension EditComponentViewProvider {
    
    func viewFor(_ component: PositionComponent) -> AnyView? { nil }
    func viewFor(_ component: OrientationComponent) -> AnyView? { nil }
    func viewFor(_ component: ScaleComponent) -> AnyView? { nil }
    func viewFor(_ component: TransformationComponent) -> AnyView? { nil }
    func viewFor(_ component: GeneratorComponent) -> AnyView? { nil }
    
}


struct GeneratorEditComponentViewProvider: EditComponentViewProvider {
    
    func viewFor(_ component: GeneratorComponent) -> AnyView? {
        AnyView(EditGeneratorComponentView(component: component))
    }
    
}
