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
    
    private var xAxisObject: SPTObject!
    private var yAxisObject: SPTObject!
    private var zAxisObject: SPTObject!

    typealias FieldComponent = AnimatorBindingSetupComponent<CartesianPositionFieldAnimatorBindingComponent>
    
    lazy private(set) var x = FieldComponent(animatableProperty: .cartesianPositionX, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var y = FieldComponent(animatableProperty: .cartesianPositionY, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var z = FieldComponent(animatableProperty: .cartesianPositionZ, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
        
        setupAxis()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(xAxisObject)
        SPTSceneProxy.destroyObject(yAxisObject)
        SPTSceneProxy.destroyObject(zAxisObject)
    }
    
    override var title: String {
        "Animators"
    }
    
    override func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: yAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
    }
    
    override func onClose() {
        SPTPolylineLook.destroy(object: xAxisObject)
        SPTPolylineLook.destroy(object: yAxisObject)
        SPTPolylineLook.destroy(object: zAxisObject)
    }
    
    override var subcomponents: [Component]? { [x, y, z] }
    
    private func setupAxis() {
        
        let origin = SPTPosition.get(object: object)
        
        xAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: xAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: xAxisObject)
        SPTPolylineLookDepthBias.make(.guideLineLayer2, object: xAxisObject)
        
        yAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: yAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: yAxisObject)
        SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, 0.0, Float.pi * 0.5), order: .XYZ)), object: yAxisObject)
        SPTPolylineLookDepthBias.make(.guideLineLayer2, object: yAxisObject)
        
        zAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: zAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: zAxisObject)
        SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ)), object: zAxisObject)
        SPTPolylineLookDepthBias.make(.guideLineLayer2, object: zAxisObject)
    }
    
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
