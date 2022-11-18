//
//  MeshLookAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.11.22.
//

import Foundation


class MeshLookAnimatorBindingsComponent: Component, BasicToolSelectedObjectRootComponent {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    lazy private(set) var shininess = AnimatorBindingSetupComponent<ShininessAnimatorBindingComponent>(animatableProperty: .shininess, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    lazy private(set) var color = ObjectColorAnimatorBindingComponent<SPTMeshLook>(keyPath: \.shading.blinnPhong.color, object: object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [shininess, color] }
    
}
