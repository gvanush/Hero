//
//  CylindricalPositionAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.05.23.
//

import SwiftUI

struct CylindricalPositionAnimatorBindingsElement: Element {
    
    let object: SPTObject
    
    @State private var radiusLineObject: SPTObject!
    @State private var heightLineObject: SPTObject!
    @State private var circleObject: SPTObject!
    @State private var circleCenterObject: SPTObject!
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    var content: some Element {
        LinearPositionPropertyAnimatorBindingElement(title: "Radius", normAxisDirection: radiusNormAxisDirection, animatableProperty: .cylindricalPositionRadius, object: object)
        LinearPositionPropertyAnimatorBindingElement(title: "Height", normAxisDirection: .up, animatableProperty: .cylindricalPositionHeight, object: object, guideColor: .guide2Dark, activeGuideColor: .guide2Light)
        RadialPositionPropertyAnimatorBindingElement(title: "Longitude", origin: longitudeOrigin, normRotationAxis: .up, animatableProperty: .cylindricalPositionLongitude, object: object, guideColor: .guide3Dark, activeGuideColor: .guide3Light)
    }
    
    var longitudeOrigin: simd_float3 {
        let cylindrical = SPTPosition.get(object: object).cylindrical
        return .init(x: cylindrical.origin.x, y: cylindrical.origin.y + cylindrical.height, z: cylindrical.origin.z)
    }
    
    var radiusNormAxisDirection: simd_float3 {
        let position = SPTPosition.get(object: object)
        let cartesian = position.cylindrical.toCartesian
        return (position.cylindrical.radius.sign == .plus ? 1.0 : -1.0) * simd_normalize(simd_float3(x: cartesian.x - position.cylindrical.origin.x, y: 0.0, z: cartesian.z - position.cylindrical.origin.z))
    }
    
    func onActive() {
        sceneViewModel.focusedObject = object
    }
    
    func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide2.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: heightLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide3.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: circleObject)
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointSmallSize), object: circleCenterObject)
    }
    
    func onClose() {
        SPTPolylineLook.destroy(object: radiusLineObject)
        SPTPolylineLook.destroy(object: heightLineObject)
        SPTPolylineLook.destroy(object: circleObject)
        SPTPointLook.destroy(object: circleCenterObject)
    }
    
    func onAwake() {
        let cylindricalPosition = SPTPosition.get(object: object).cylindrical
        
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindricalPosition.origin + .init(x: 0.0, y: cylindricalPosition.height, z: 0.0)), object: radiusLineObject)
        SPTScale.make(.init(x: 500.0), object: radiusLineObject)
        SPTOrientation.make(.init(eulerY: cylindricalPosition.longitude - 0.5 * Float.pi, x: 0.0, z: 0.0), object: radiusLineObject)
        
        heightLineObject = sceneViewModel.scene.makeObject()
        var heightLinePosition = SPTPosition.get(object: object)
        heightLinePosition.cylindrical.height = 0.0
        SPTPosition.make(heightLinePosition, object: heightLineObject)
        SPTScale.make(.init(y: 500.0), object: heightLineObject)
        
        let circleCenterPosition = SPTPosition(cartesian: .init(x: cylindricalPosition.origin.x, y: cylindricalPosition.origin.y + cylindricalPosition.height, z: cylindricalPosition.origin.z))
        circleObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(circleCenterPosition, object: circleObject)
        SPTScale.make(.init(x: cylindricalPosition.radius, y: cylindricalPosition.radius), object: circleObject)
        SPTOrientation.make(.init(eulerX: 0.5 * Float.pi, y: 0.0, z: 0.0), object: circleObject)
        
        circleCenterObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(circleCenterPosition, object: circleCenterObject)
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(radiusLineObject)
        SPTSceneProxy.destroyObject(heightLineObject)
        SPTSceneProxy.destroyObject(circleObject)
        SPTSceneProxy.destroyObject(circleCenterObject)
    }
    
    var id: some Hashable {
        \SPTPosition.cylindrical
    }
    
    var title: String {
        "Position"
    }
    
    var subtitle: String? {
        "Cylindrical"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
