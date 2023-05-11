//
//  CartesianPositionAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.05.23.
//

import SwiftUI


struct CartesianPositionAnimatorBindingsElement: Element {
    
    let object: SPTObject
    
    @State private var xAxisObject: SPTObject!
    @State private var yAxisObject: SPTObject!
    @State private var zAxisObject: SPTObject!
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    var content: some Element {
        LinearlyVaryingPropertyAnimatorBindingElement(title: "X", normAxisDirection: .right, animatableProperty: .cartesianPositionX, object: object, guideColor: .xAxisDark, activeGuideColor: .xAxisLight)
        LinearlyVaryingPropertyAnimatorBindingElement(title: "Y", normAxisDirection: .up, animatableProperty: .cartesianPositionY, object: object, guideColor: .yAxisDark, activeGuideColor: .yAxisLight)
        LinearlyVaryingPropertyAnimatorBindingElement(title: "Z", normAxisDirection: .backward, animatableProperty: .cartesianPositionZ, object: object, guideColor: .zAxisDark, activeGuideColor: .zAxisLight)
    }
    
    func onActive() {
        sceneViewModel.focusedObject = object
    }
    
    func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.yAxis.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: yAxisObject)
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId: sceneViewModel.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
    }
    
    func onClose() {
        SPTPolylineLook.destroy(object: xAxisObject)
        SPTPolylineLook.destroy(object: yAxisObject)
        SPTPolylineLook.destroy(object: zAxisObject)
    }
    
    func onAwake() {
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
    
    func onSleep() {
        SPTSceneProxy.destroyObject(xAxisObject)
        SPTSceneProxy.destroyObject(yAxisObject)
        SPTSceneProxy.destroyObject(zAxisObject)
    }
    
    var id: some Hashable {
        \SPTPosition.cartesian
    }
    
    var title: String {
        "Position"
    }
    
    var subtitle: String? {
        "Cartesian"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}

