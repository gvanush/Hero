//
//  XYZScaleAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 30.12.22.
//

import Foundation
import SwiftUI


class XYZScaleAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    private var xAxisObject: SPTObject!
    private var yAxisObject: SPTObject!
    private var zAxisObject: SPTObject!

    typealias FieldComponent = AnimatorBindingSetupComponent<XYZScaleFieldAnimatorBindingComponent>
    
    lazy private(set) var x = FieldComponent(animatableProperty: .xyzScaleX, defaultValueAt0: SPTScale.get(object: object).uniform / 1.5, defaultValueAt1: 1.5 * SPTScale.get(object: object).uniform, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var y = FieldComponent(animatableProperty: .xyzScaleY, defaultValueAt0: SPTScale.get(object: object).uniform / 1.5, defaultValueAt1: 1.5 * SPTScale.get(object: object).uniform, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    lazy private(set) var z = FieldComponent(animatableProperty: .xyzScaleZ, defaultValueAt0: SPTScale.get(object: object).uniform / 1.5, defaultValueAt1: 1.5 * SPTScale.get(object: object).uniform, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
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
        SPTOrientation.make(SPTOrientation.get(object: object), object: xAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: xAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: xAxisObject)
        
        yAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: yAxisObject)
        SPTOrientation.make(SPTOrientation.get(object: object), object: yAxisObject)
        SPTScale.make(.init(xyz: simd_float3(1.0, 500.0, 1.0)), object: yAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: yAxisObject)
        
        zAxisObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(origin, object: zAxisObject)
        SPTOrientation.make(SPTOrientation.get(object: object), object: zAxisObject)
        SPTScale.make(.init(xyz: simd_float3(1.0, 1.0, 500.0)), object: zAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: zAxisObject)
    }
    
}

