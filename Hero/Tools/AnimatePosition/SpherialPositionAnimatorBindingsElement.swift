//
//  SpherialPositionAnimatorBindingsElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11.05.23.
//

import SwiftUI


struct SpherialPositionAnimatorBindingsElement: Element {
    
    let object: SPTObject
    
    @State private var radiusLineObject: SPTObject!
    @State private var latitudeCircleObject: SPTObject!
    @State private var longitudeCircleObject: SPTObject!
    @State private var originObject: SPTObject!
    
    @EnvironmentObject private var sceneViewModel: SceneViewModel
    
    var content: some Element {
        LinearPropertyAnimatorBindingElement(title: "Radius", normAxisDirection: radiusNormAxisDirection, animatableProperty: .sphericalPositionRadius, object: object)
        RadialPropertyAnimatorBindingElement(title: "Latitude", origin: SPTPosition.get(object: object).spherical.origin, normRotationAxis: latitudeNormAxisDirection, animatableProperty: .sphericalPositionLatitude, object: object, guideColor: .guide2Dark, activeGuideColor: .guide2Light)
        RadialPropertyAnimatorBindingElement(title: "Longitude", origin: longitudeOrigin, normRotationAxis: .up, animatableProperty: .sphericalPositionLongitude, object: object, guideColor: .guide3Dark, activeGuideColor: .guide3Light)
    }
    
    var radiusNormAxisDirection: simd_float3 {
        let position = SPTPosition.get(object: object)
        let cartesian = position.spherical.toCartesian
        return (position.spherical.radius.sign == .plus ? 1.0 : -1.0) * simd_normalize(cartesian - position.spherical.origin)
    }
    
    var latitudeNormAxisDirection: simd_float3 {
        let position = SPTPosition.get(object: object)
        let angle = 0.5 * Float.pi + position.spherical.longitude
        return .init(x: sinf(angle), y: 0.0, z: cosf(angle))
    }
    
    var longitudeOrigin: simd_float3 {
        let position = SPTPosition.get(object: object)
        return .init(x: position.spherical.origin.x, y: position.spherical.toCartesian.y, z: position.spherical.origin.z)
    }
    
    func onActive() {
        sceneViewModel.focusedObject = object
    }
    
    func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide2.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: latitudeCircleObject)
        SPTPolylineLook.make(.init(color: UIColor.guide3.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: longitudeCircleObject)
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointLargeSize), object: originObject)
    }
    
    func onClose() {
        SPTPolylineLook.destroy(object: radiusLineObject)
        SPTPolylineLook.destroy(object: latitudeCircleObject)
        SPTPolylineLook.destroy(object: longitudeCircleObject)
        SPTPointLook.destroy(object: originObject)
    }
    
    func onAwake() {
        let sphericalPosition = SPTPosition.get(object: object).spherical
        let objectCartesian = sphericalPosition.toCartesian
        let radiusDirection = objectCartesian - sphericalPosition.origin
        let radiusNormDirection = simd_normalize(radiusDirection)
        
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: sphericalPosition.origin), object: radiusLineObject)
        SPTScale.make(.init(x: 500.0), object: radiusLineObject)

        // Make sure up and direction vectors are not collinear for correct line orientation
        let radiusUpVector: simd_float3 = SPTVector.collinear(radiusNormDirection, .up, tolerance: 0.0001) ? .left : .up
        SPTOrientation.make(.init(normDirection: radiusNormDirection, up: radiusUpVector, axis: .X), object: radiusLineObject)
        
        latitudeCircleObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: sphericalPosition.origin), object: latitudeCircleObject)
        SPTScale.make(.init(x: sphericalPosition.radius, y: sphericalPosition.radius), object: latitudeCircleObject)
        SPTOrientation.make(.init(eulerY: 0.5 * Float.pi + sphericalPosition.longitude, x: 0.0, z: 0.0), object: latitudeCircleObject)
        
        longitudeCircleObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: .init(x: sphericalPosition.origin.x, y: objectCartesian.y, z: sphericalPosition.origin.z)), object: longitudeCircleObject)
        
        let scale = simd_length(.init(x: radiusDirection.x, y: radiusDirection.z))
        SPTScale.make(.init(x: scale, y: scale), object: longitudeCircleObject)
        SPTOrientation.make(.init(eulerX: 0.5 * Float.pi, y: 0.0, z: 0.0), object: longitudeCircleObject)
        
        originObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: sphericalPosition.origin), object: originObject)
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(radiusLineObject)
        SPTSceneProxy.destroyObject(latitudeCircleObject)
        SPTSceneProxy.destroyObject(longitudeCircleObject)
        SPTSceneProxy.destroyObject(originObject)
    }
    
    var id: some Hashable {
        \SPTPosition.spherical
    }
    
    var title: String {
        "Position"
    }
    
    var subtitle: String? {
        "Spherical"
    }
    
    var _activeIndexPath: Binding<IndexPath>!
    var indexPath: IndexPath!
    @Namespace var namespace
    
}
