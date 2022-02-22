//
//  ScaleComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.02.22.
//

import Foundation
import Combine
import SwiftUI


final class ScaleComponent: MultiVariantComponent {
    
    enum VariantTag: Int, DistinctValueSet, Displayable {
        case nonuniform
        case uniform
    }
    
    @Published var variantTag = VariantTag.nonuniform
    private lazy var nonuniformVariant = NonuniformScaleComponent(parent: self)
    private lazy var uniformVariant = UniformScaleComponent(parent: self)
    
    let object: SPTObject
    
    init(object: SPTObject, parent: Component?) {
        self.object = object
        super.init(title: "Scale", parent: parent)
    }
    
    override var variants: [Component]! {
        [nonuniformVariant, uniformVariant]
    }
    
    override var activeVariantIndex: Int! {
        set { variantTag = .init(rawValue: newValue)! }
        get { variantTag.rawValue }
    }
}

final class NonuniformScaleComponent: BasicComponent<Axis> {
    init(parent: Component?) {
        super.init(title: "Nonuniform Scale", selectedProperty: .x, parent: parent)
    }
}

enum UniformScaleComponentProperty: Int, DistinctValueSet, Displayable {
    case scale
}

final class UniformScaleComponent: BasicComponent<UniformScaleComponentProperty> {
    
    init(parent: Component?) {
        super.init(title: "Uniform Scale", selectedProperty: .scale, parent: parent)
    }
    
}
