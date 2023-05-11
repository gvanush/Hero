//
//  LinearPositionAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.05.23.
//

import SwiftUI


struct LinearPositionAnimatorBindingsElement: Element {
    
    let object: SPTObject
    
    @State private var originGuideObject: SPTObject!
    @State private var lineGuideObject: SPTObject!
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    var content: some Element {
        LinearlyVaryingPropertyAnimatorBindingElement(title: "Offset", normAxisDirection: simd_normalize(SPTPosition.get(object: object).linear.direction), animatableProperty: .linearPositionOffset, object: object)
    }
    
    func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: lineGuideObject)
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointLargeSize), object: originGuideObject)
    }
    
    func onClose() {
        SPTPolylineLook.destroy(object: lineGuideObject)
        SPTPointLook.destroy(object: originGuideObject)
    }
    
    func onAwake() {
        let position = SPTPosition.get(object: object)
        let originPosition = SPTPosition(cartesian: position.linear.origin)
        
        lineGuideObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(originPosition, object: lineGuideObject)
        SPTScale.make(.init(x: 500.0), object: lineGuideObject)
        
        let lineUpVector: simd_float3 = SPTVector.collinear(position.linear.direction, .up, tolerance: 0.0001) ? .left : .up
        SPTOrientation.make(.init(normDirection: simd_normalize(position.linear.direction), up: lineUpVector, axis: .X), object: lineGuideObject)
        
        SPTLineLookDepthBias.make(.guideLineLayer2, object: lineGuideObject)
        
        originGuideObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(originPosition, object: originGuideObject)
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(originGuideObject)
        SPTSceneProxy.destroyObject(lineGuideObject)
    }
    
    var id: some Hashable {
        \SPTPosition.linear
    }
    
    var title: String {
        "Position"
    }
    
    var subtitle: String? {
        "Linear"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
