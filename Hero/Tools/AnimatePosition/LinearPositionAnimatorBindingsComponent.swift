//
//  LinearPositionAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.22.
//

import SwiftUI


class LinearPositionAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    typealias FieldComponent = AnimatorBindingSetupComponent<LinearPositionOffsetAnimatorBindingComponent>

    lazy private(set) var offset = FieldComponent(animatableProperty: .linearPositionOffset, object: self.object, sceneViewModel: sceneViewModel, parent: self)
        
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [offset] }
    
}


class LinearPositionOffsetAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard animatableProperty == .linearPositionOffset && position.coordinateSystem == .linear else {
            fatalError()
        }

        super.init(axisDirection: position.linear.direction, editingParamsKeyPath: \.[linearPositionBindingOf: object].offset, animatableProperty: .linearPositionOffset, object: object, sceneViewModel: sceneViewModel, parent: parent)
    }
    
}
