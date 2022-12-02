//
//  PositionAnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI
import Combine


class CartesianPositionAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel

    typealias FieldComponent = AnimatorBindingSetupComponent<CartesianPositionFieldAnimatorBindingComponent>
    
    lazy private(set) var x = FieldComponent(animatableProperty: .cartesianPositionX, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var y = FieldComponent(animatableProperty: .cartesianPositionY, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var z = FieldComponent(animatableProperty: .cartesianPositionZ, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [x, y, z] }
    
}


class CartesianPositionFieldAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard position.coordinateSystem == .cartesian else {
            fatalError()
        }
        
        var axisDirection: simd_float3!
        var editingParamsKeyPath: ReferenceWritableKeyPath<ObjectPropertyEditingParams, AnimatorBindingEditingParams>!
        
        switch animatableProperty {
        case .cartesianPositionX:
            axisDirection = .right
            editingParamsKeyPath = \.[cartesianPositionBindingOf: object].x
        case .cartesianPositionY:
            axisDirection = .up
            editingParamsKeyPath = \.[cartesianPositionBindingOf: object].y
        case .cartesianPositionZ:
            axisDirection = .backward
            editingParamsKeyPath = \.[cartesianPositionBindingOf: object].z
        default:
            fatalError()
        }
        
        super.init(axisDirection: axisDirection, editingParamsKeyPath: editingParamsKeyPath, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
    }
    
}
