//
//  PositionAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.22.
//

import Foundation
import Combine


class PositionAnimatorBindingsComponent: MultiVariantComponent, BasicToolSelectedObjectRootComponent {
    
    private let object: SPTObject
    private let sceneViewModel: SceneViewModel
    private var colorModelSubscription: SPTAnySubscription?
    private var variantCancellable: AnyCancellable?
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        super.init(parent: parent)
        
        colorModelSubscription = SPTPosition.onDidChangeSink(object: object) { [unowned self] oldValue in
            if oldValue.coordinateSystem != self.coordinateSystem {
                self.setupVariant()
            }
        }
        
        setupVariant()
        
    }
    
    var coordinateSystem: SPTCoordinateSystem {
        SPTPosition.get(object: object).coordinateSystem
    }
 
    private func setupVariant() {
        self.variantTag = coordinateSystem.rawValue
        switch coordinateSystem {
        case .cartesian:
            activeComponent = CartesianPositionAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
        case .linear:
            activeComponent = LinearPositionAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: parent)
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
