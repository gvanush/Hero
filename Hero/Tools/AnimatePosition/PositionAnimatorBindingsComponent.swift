//
//  PositionAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.22.
//

import SwiftUI
import Combine


class PositionAnimatorBindingsComponent: MultiVariantComponent, BasicToolSelectedObjectRootComponent {
    
    private let object: SPTObject
    private let sceneViewModel: SceneViewModel
    private var variantCancellable: AnyCancellable?
    private var originPointObject: SPTObject
    private var positionSubscription: SPTAnySubscription?
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        originPointObject = sceneViewModel.scene.makeObject()
        
        super.init(parent: parent)
        
        let position = SPTPosition.get(object: object)
        SPTPosition.make(position, object: originPointObject)
        
        positionSubscription = SPTPosition.onDidChangeSink(object: object) { [unowned self] oldValue in
            let newValue = SPTPosition.get(object: object)
            SPTPosition.update(newValue, object: self.originPointObject)
            if oldValue.coordinateSystem != newValue.coordinateSystem {
                self.setupVariant(coordinateSystem: newValue.coordinateSystem)
            }
        }
        
        setupVariant(coordinateSystem: position.coordinateSystem)
        
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
 
    private func setupVariant(coordinateSystem: SPTCoordinateSystem) {
        self.variantTag = coordinateSystem.rawValue
        switch coordinateSystem {
        case .cartesian:
            break
        case .linear:
            break
        case .spherical:
            activeComponent = SphericalPositionAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .cylindrical:
            activeComponent = CylindricalPositionAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        }
        variantCancellable = activeComponent.objectWillChange.sink { [unowned self] in
            self.objectWillChange.send()
        }
    }
    
}
