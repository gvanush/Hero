//
//  MeshLookAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.11.22.
//

import Foundation


class MeshLookAnimatorBindingsComponent: Component, BasicToolSelectedObjectRootComponent {
    
    struct EditingParams {
        var shininess = ShininessAnimatorBindingComponent.EditingParams()
        var color = ObjectColorAnimatorBindingComponent<SPTMeshLook>.EditingParams()
    }
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    private let initialEditingParams: EditingParams
    
    lazy private(set) var shininess = AnimatorBindingSetupComponent<ShininessAnimatorBindingComponent>(initialEditingParams: initialEditingParams.shininess, animatableProperty: .shininess, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    lazy private(set) var color = ObjectColorAnimatorBindingComponent<SPTMeshLook>(editingParams: initialEditingParams.color, keyPath: \.shading.blinnPhong.color, object: object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(editingParams: EditingParams, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        self.initialEditingParams = editingParams
        super.init(parent: parent)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [shininess, color] }
    
    var editingParams: EditingParams {
        .init(shininess: shininess.editingParams, color: color.editingParams)
    }
    
}
