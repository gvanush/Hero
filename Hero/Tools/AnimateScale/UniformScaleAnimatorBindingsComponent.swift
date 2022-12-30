//
//  UniformScaleAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 30.12.22.
//

import Foundation

class UniformScaleAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    typealias FieldComponent = AnimatorBindingSetupComponent<UniformScaleFieldAnimatorBindingComponent>
    
    lazy private(set) var uniform = FieldComponent(animatableProperty: .uniformScale, defaultValueAt0: SPTScale.get(object: object).uniform / 1.5, defaultValueAt1: 1.5 * SPTScale.get(object: object).uniform, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [uniform] }
}
