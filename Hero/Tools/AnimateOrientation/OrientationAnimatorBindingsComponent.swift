//
//  OrientationAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.23.
//

import Foundation
import Combine


class OrientationAnimatorBindingsComponent: MultiVariantComponent, BasicToolSelectedObjectRootComponent {
    
    private let object: SPTObject
    private let sceneViewModel: SceneViewModel
    private var variantCancellable: AnyCancellable?
    private var originPointObject: SPTObject
    private var orientationSubscription: SPTAnySubscription?
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        
        super.init(parent: parent)
        
        let position = SPTPosition.get(object: object)
        SPTPosition.make(position, object: originPointObject)
        
        orientationSubscription = SPTOrientation.onDidChangeSink(object: object) { [unowned self] oldValue in
            let newValue = SPTOrientation.get(object: object)
            if oldValue.model != newValue.model {
                self.setupVariant(orientationModel: newValue.model)
            }
        }
        
        setupVariant(orientationModel: SPTOrientation.get(object: object).model)
        
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
 
    private func setupVariant(orientationModel: SPTOrientationModel) {
        self.variantTag = orientationModel.rawValue
        switch orientationModel {
        case .eulerXYZ, .eulerXZY, .eulerYXZ, .eulerYZX, .eulerZXY, .eulerZYX:
            activeComponent = EulerOrientationAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        default:
            fatalError()
        }
        variantCancellable = activeComponent.objectWillChange.sink { [unowned self] in
            self.objectWillChange.send()
        }
    }
    
}
