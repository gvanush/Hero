//
//  ScaleAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 30.12.22.
//

import Foundation
import Combine


class ScaleAnimatorBindingsComponent: MultiVariantComponent, BasicToolSelectedObjectRootComponent {
    
    private let object: SPTObject
    private let sceneViewModel: SceneViewModel
    private var variantCancellable: AnyCancellable?
    private var originPointObject: SPTObject
    
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: originPointObject)
        
        super.init(parent: parent)
        
        setupVariant()
        
    }
    
    deinit {
        SPTSceneProxy.destroyObject(originPointObject)
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: originPointObject)
    }
 
    private func setupVariant() {
        let scaleModel = SPTScale.get(object: object).model
        self.variantTag = scaleModel.rawValue
        switch scaleModel {
        case .XYZ:
            activeComponent = XYZScaleAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .uniform:
            activeComponent = UniformScaleAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        }
        variantCancellable = activeComponent.objectWillChange.sink { [unowned self] in
            self.objectWillChange.send()
        }
    }
    
}
