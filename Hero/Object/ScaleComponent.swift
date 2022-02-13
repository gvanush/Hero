//
//  ScaleComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.02.22.
//

import Foundation
import Combine
import SwiftUI


class ScaleComponent: MultiVariantComponent2<NonuniformScaleComponentVariant, UniformScaleComponentVariant> {
    
    enum VariantTag {
        case nonuniform
        case uniform
    }
    
    init(parent: Component?) {
        super.init(title: "Scale", variantTag: .nonuniform, parent: parent)
    }
    
}

class NonuniformScaleComponentVariant: ComponentVariant {
    
    @Published var selected: Axis? = .x
    
    required init() {}
    
    static var tag: ScaleComponent.VariantTag {
        ScaleComponent.VariantTag.nonuniform
    }
}

class UniformScaleComponentVariant: ComponentVariant {
    
    enum Property: Int, DistinctValueSet, Displayable {
        case scale
    }
    
    @Published var selected: Property? = .scale
    
    required init() {}
    
    static var tag: ScaleComponent.VariantTag {
        ScaleComponent.VariantTag.uniform
    }
    
}
