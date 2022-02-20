//
//  ScaleComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.02.22.
//

import Foundation
import Combine
import SwiftUI


class ScaleComponent: Component {
    
    enum VariantTag: DistinctValueSet, Displayable {
        case nonuniform
        case uniform
    }
    
    @Published var variantTag = VariantTag.nonuniform
    
    let object: SPTObject
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Scale", parent: parent)
    }
    
}

class NonuniformScaleComponentVariant: ComponentVariant {
    
    @Published var selected: Axis? = .x
    
    static var tag: ScaleComponent.VariantTag {
        ScaleComponent.VariantTag.nonuniform
    }
}

class UniformScaleComponentVariant: ComponentVariant {
    
    enum Property: Int, DistinctValueSet, Displayable {
        case scale
    }
    
    @Published var selected: Property? = .scale
    
    static var tag: ScaleComponent.VariantTag {
        ScaleComponent.VariantTag.uniform
    }
    
}
