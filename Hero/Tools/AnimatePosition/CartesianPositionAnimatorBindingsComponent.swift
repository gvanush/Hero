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
    
    lazy private(set) var x = FieldComponent(animatableProperty: .cartesianPositionX, defaultValueAt0: -5.0, defaultValueAt1: 5.0, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var y = FieldComponent(animatableProperty: .cartesianPositionY, defaultValueAt0: -5.0, defaultValueAt1: 5.0, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var z = FieldComponent(animatableProperty: .cartesianPositionZ, defaultValueAt0: -5.0, defaultValueAt1: 5.0, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
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
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.yAxis.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: yAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId: sceneViewModel.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
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
        SPTLineLookDepthBias.make(.guideLineLayer2, object: xAxisObject)
        
        yAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: yAxisObject)
        SPTScale.make(.init(xyz: simd_float3(1.0, 500.0, 1.0)), object: yAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: yAxisObject)
        
        zAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: zAxisObject)
        SPTScale.make(.init(xyz: simd_float3(1.0, 1.0, 500.0)), object: zAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: zAxisObject)
    }
    
}


class CartesianPositionFieldAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard position.coordinateSystem == .cartesian else {
            fatalError()
        }
        
        var axisDirection: simd_float3!
        switch animatableProperty {
        case .cartesianPositionX:
            axisDirection = .right
        case .cartesianPositionY:
            axisDirection = .up
        case .cartesianPositionZ:
            axisDirection = .backward
        default:
            fatalError()
        }
        
        super.init(normAxisDirection: axisDirection, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        switch animatableProperty {
        case .cartesianPositionX:
            guideColor = .xAxisDark
            selectedGuideColor = .xAxisLight
        case .cartesianPositionY:
            guideColor = .yAxisDark
            selectedGuideColor = .yAxisLight
        case .cartesianPositionZ:
            guideColor = .zAxisDark
            selectedGuideColor = .zAxisLight
        default:
            fatalError()
        }
    }
    
}
