//
//  XYZScaleAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 13.05.23.
//

import SwiftUI


struct XYZScaleAnimatorBindingsElement: Element {
    
    let object: SPTObject
    let twinObject: SPTObject
    
    @StateObject private var twinXYZ: SPTObservableComponentProperty<SPTScale, simd_float3>
    
    init(object: SPTObject, twinObject: SPTObject) {
        self.object = object
        self.twinObject = twinObject
        _twinXYZ = .init(wrappedValue: .init(object: twinObject, keyPath: \.xyz))
    }
    
    @State private var xAxisObject: SPTObject!
    @State private var yAxisObject: SPTObject!
    @State private var zAxisObject: SPTObject!
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    var content: some Element {
        LinearScalePropertyAnimatorBindingElement(title: "X", normAxisDirection: .right, propertyValue: $twinXYZ.x, animatableProperty: .xyzScaleX, object: object, defaultValueAt0: objectXYZ.x / 1.5, defaultValueAt1: objectXYZ.x * 1.5, guideColor: .xAxis, activeGuideColor: .xAxisLight)
        LinearScalePropertyAnimatorBindingElement(title: "Y", normAxisDirection: .up, propertyValue: $twinXYZ.y, animatableProperty: .xyzScaleY, object: object, defaultValueAt0: objectXYZ.y / 1.5, defaultValueAt1: objectXYZ.y * 1.5, guideColor: .yAxis, activeGuideColor: .yAxisLight)
        LinearScalePropertyAnimatorBindingElement(title: "Z", normAxisDirection: .backward, propertyValue: $twinXYZ.z, animatableProperty: .xyzScaleZ, object: object, defaultValueAt0: objectXYZ.z / 1.5, defaultValueAt1: objectXYZ.z * 1.5, guideColor: .zAxis, activeGuideColor: .zAxisLight)
    }
    
    var objectXYZ: simd_float3 {
        SPTScale.get(object: object).xyz
    }
    
    func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        
        SPTPolylineLook.make(.init(color: UIColor.yAxis.rgba, polylineId: MeshRegistry.util.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: yAxisObject)
        
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId:MeshRegistry.util.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
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
    
    func onSleep() {
        SPTSceneProxy.destroyObject(xAxisObject)
        SPTSceneProxy.destroyObject(yAxisObject)
        SPTSceneProxy.destroyObject(zAxisObject)
    }
    
    var id: some Hashable {
        \SPTScale.xyz
    }
    
    var title: String {
        "Scale"
    }
    
    var subtitle: String? {
        "XYZ"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
