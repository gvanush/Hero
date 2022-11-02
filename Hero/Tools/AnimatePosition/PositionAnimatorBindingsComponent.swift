//
//  PositionAnimatorBindingComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import SwiftUI


class PositionFieldAnimatorBindingComponent: AnimatorBindingComponent<SPTAnimatableObjectProperty> {
    
    typealias EditingParams = EditPositionAnimatorBindingViewModel.EditingParams
    
    let axis: Axis
    let sceneViewModel: SceneViewModel
    private let initialEditingParams: EditingParams
    
    init(editingParams: EditingParams, axis: Axis, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.axis = axis
        self.sceneViewModel = sceneViewModel
        self.initialEditingParams = editingParams
        
        var animatableProperty: SPTAnimatableObjectProperty!
        switch axis {
        case .x:
            animatableProperty = .positionX
        case .y:
            animatableProperty = .positionY
        case .z:
            animatableProperty = .positionZ
        }
        
        super.init(animatableProperty: animatableProperty, title: "\(axis.displayName) Binding", object: object, parent: parent)
    }
    
    override func makeEditViewModel() -> EditAnimatorBindingViewModel<SPTAnimatableObjectProperty>? {
        EditPositionAnimatorBindingViewModel(editingParams: initialEditingParams, axis: axis, object: object, sceneViewModel: sceneViewModel)
    }
    
    var editingParams: EditingParams {
        editViewModel?.editingParams ?? initialEditingParams
    }
}


class PositionAnimatorBindingsComponent: Component, BasicToolSelectedObjectRootComponent {
    
    struct EditingParams {
        var x = PositionFieldAnimatorBindingComponent.EditingParams()
        var y = PositionFieldAnimatorBindingComponent.EditingParams()
        var z = PositionFieldAnimatorBindingComponent.EditingParams()
    }
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    private let initialEditingParams: EditingParams
    
    lazy private(set) var x = PositionFieldAnimatorBindingComponent(editingParams: initialEditingParams.x, axis: .x, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var y = PositionFieldAnimatorBindingComponent(editingParams: initialEditingParams.y, axis: .y, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var z = PositionFieldAnimatorBindingComponent(editingParams: initialEditingParams.z, axis: .z, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(editingParams: EditingParams, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        self.initialEditingParams = editingParams
        super.init(title: "Animators", parent: parent)
    }
    
    override var subcomponents: [Component]? { [x, y, z] }
    
    var editingParams: EditingParams {
        .init(x: x.editingParams, y: y.editingParams, z: z.editingParams)
    }
}
