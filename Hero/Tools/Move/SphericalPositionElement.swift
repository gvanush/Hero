//
//  SphericalPositionElement.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.04.23.
//

import SwiftUI

struct SphericalPositionElement: Element {

    static let keyPath = \SPTPosition.spherical
    static let originKeyPath = \SPTPosition.spherical.origin
    
    enum Property: Int, ElementProperty {
        case radius
        case latitude
        case longitude
    }
    
    @ObservedObject @ObservableAnyUserObject var object: any UserObject
    
    @ObjectElementActiveProperty var activeProperty: Property
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var originObject: SPTObject!
    @State private var latitudeCircleObject: SPTObject!
    @State private var longitudeCircleObject: SPTObject!
    @State private var radiusLineObject: SPTObject!
    
    init(object: any UserObject) {
        _object = .init(wrappedValue: .init(wrappedValue: object))
        _activeProperty = .init(object: object.sptObject, elementId: Self.keyPath)
    }
    
    var body: some View {
        elementBody
            .onChange(of: object.position.spherical) { newValue in
                updateGuideObjects(spherical: newValue)
            }
    }
    
    var content: some Element {
        CartesianPositionElement(title: "Origin", subtitle: nil, object: object, keyPath: Self.originKeyPath, position: .init(get: {
            object.position.spherical.origin
        }, set: {
            SPTPosition.update(.init(cartesian: $0), object: originObject)
            object.position.spherical.origin = $0
        }))
        .onDisclose(onOriginDisclose)
        .onClose(onOriginClose)
        .controlTint(.guide1Light)
    }
    
    func onOriginDisclose() {
        var pointLook = SPTPointLook.get(object: originObject)
        pointLook.color = UIColor.guide1Light.rgba
        SPTPointLook.update(pointLook, object: originObject)
        sceneViewModel.focusedObject = originObject
    }
    
    func onOriginClose() {
        guard SPTIsValid(originObject) else {
            return
        }
        guard var pointLook = SPTPointLook.tryGet(object: originObject) else {
            return
        }
        pointLook.color = UIColor.guide1.rgba
        SPTPointLook.update(pointLook, object: originObject)
    }
    
    var actionView: some View {
        Group {
            switch activeProperty {
            case .radius:
                ObjectFloatPropertySelector(object: object.sptObject, id: Self.keyPath.appending(path: \.radius), value: $object.position.spherical.radius, formatter: Formatters.distance)
            case .latitude:
                ObjectFloatPropertySelector(object: object.sptObject, id: Self.keyPath.appending(path: \.latitudeInDegrees), value: $object.position.spherical.latitudeInDegrees, formatter: Formatters.angle)
            case .longitude:
                ObjectFloatPropertySelector(object: object.sptObject, id: Self.keyPath.appending(path: \.longitudeInDegrees), value: $object.position.spherical.longitudeInDegrees, formatter: Formatters.angle)
            }
        }
        .tint(.primarySelectionColor)
    }
    
    var optionsView: some View {
        ObjectCoordinateSystemSelector(object: object)
    }
    
    func onActivePropertyChange() {
        updateActiveGuideObject()
    }
    
    func onActive() {
        updateActiveGuideObject()
        sceneViewModel.focusedObject = object.sptObject
    }
    
    func onInactive() {
        updateActiveGuideObject()
    }
    
    func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointLargeSize, categories: LookCategories.guide.rawValue), object: originObject)
        SPTPolylineLook.make(.init(color: UIColor.guide2.rgba, polylineId: MeshRegistry.util.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: latitudeCircleObject)
        SPTPolylineLook.make(.init(color: UIColor.guide3.rgba, polylineId: MeshRegistry.util.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: longitudeCircleObject)
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
    }
    
    func onClose() {
        SPTPointLook.destroy(object: originObject)
        SPTPolylineLook.destroy(object: latitudeCircleObject)
        SPTPolylineLook.destroy(object: longitudeCircleObject)
        SPTPolylineLook.destroy(object: radiusLineObject)
    }
    
    func onAwake() {
        
        let spherical = object.position.spherical
        
        // Setup origin
        originObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: spherical.origin), object: originObject)
        
        // Setup latitude circle
        latitudeCircleObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: spherical.origin), object: latitudeCircleObject)
        SPTScale.make(.init(x: spherical.radius, y: spherical.radius), object: latitudeCircleObject)
        SPTOrientation.make(.init(eulerY: 0.5 * Float.pi + spherical.longitude, x: 0.0, z: 0.0), object: latitudeCircleObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: latitudeCircleObject)
        
        // Setup longitude circle
        longitudeCircleObject = sceneViewModel.scene.makeObject()
        
        let cartesian = SPTSphericalCoordinatesToCartesian(spherical)
        SPTPosition.make(.init(x: spherical.origin.x, y: cartesian.y, z: spherical.origin.z), object: longitudeCircleObject)
        
        let vec = cartesian - spherical.origin
        let scale = simd_length(.init(x: vec.x, y: vec.z))
        
        SPTScale.make(.init(x: scale, y: scale), object: longitudeCircleObject)
        SPTOrientation.make(.init(eulerX: 0.5 * Float.pi, y: 0.0, z: 0.0), object: longitudeCircleObject)
        SPTLineLookDepthBias.make(.guideLineLayer2, object: longitudeCircleObject)
        
        // Setup radius line
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: spherical.origin), object: radiusLineObject)
        SPTScale.make(.init(x: 500.0), object: radiusLineObject)
        
        let direction = simd_normalize(cartesian - spherical.origin)
        SPTOrientation.make(.init(normDirection: direction, up: radiusUpVector(direction: direction), axis: .X), object: radiusLineObject)
        
        SPTLineLookDepthBias.make(.guideLineLayer2, object: radiusLineObject)
    }
    
    func onSleep() {
        SPTSceneProxy.destroyObject(originObject)
        SPTSceneProxy.destroyObject(latitudeCircleObject)
        SPTSceneProxy.destroyObject(longitudeCircleObject)
        SPTSceneProxy.destroyObject(radiusLineObject)
    }
    
    private func updateActiveGuideObject() {
        
        var radiusLineLook = SPTPolylineLook.get(object: self.radiusLineObject)
        var latitudeCircleLook = SPTPolylineLook.get(object: self.latitudeCircleObject)
        var longitudeCircleLook = SPTPolylineLook.get(object: self.longitudeCircleObject)

        switch activeProperty {
        case .latitude:
            radiusLineLook.color = UIColor.guide1.rgba
            latitudeCircleLook.color = isActive ? UIColor.guide2Light.rgba : UIColor.guide2.rgba
            longitudeCircleLook.color = UIColor.guide3.rgba
        case .longitude:
            radiusLineLook.color = UIColor.guide1.rgba
            latitudeCircleLook.color = UIColor.guide2.rgba
            longitudeCircleLook.color = isActive ? UIColor.guide3Light.rgba : UIColor.guide3.rgba
        case .radius:
            radiusLineLook.color = isActive ? UIColor.guide1Light.rgba : UIColor.guide1.rgba
            latitudeCircleLook.color = UIColor.guide2.rgba
            longitudeCircleLook.color = UIColor.guide3.rgba
        }

        SPTPolylineLook.update(radiusLineLook, object: self.radiusLineObject)
        SPTPolylineLook.update(latitudeCircleLook, object: self.latitudeCircleObject)
        SPTPolylineLook.update(longitudeCircleLook, object: self.longitudeCircleObject)
        
    }
    
    private func updateGuideObjects(spherical: SPTSphericalCoordinates) {
        let cartesian = SPTSphericalCoordinatesToCartesian(spherical)
        let lineDirection = simd_normalize(cartesian - spherical.origin)
        
        SPTPosition.update(.init(cartesian: spherical.origin), object: radiusLineObject)
        SPTOrientation.update(.init(normDirection: lineDirection, up: radiusUpVector(direction: lineDirection), axis: .X), object: radiusLineObject)

        SPTPosition.update(.init(cartesian: spherical.origin), object: latitudeCircleObject)
        SPTScale.update(.init(x: spherical.radius, y: spherical.radius), object: latitudeCircleObject)
        SPTOrientation.update(.init(eulerY: 0.5 * Float.pi + spherical.longitude, x: 0.0, z: 0.0), object: latitudeCircleObject)
        
        SPTPosition.update(.init(x: spherical.origin.x, y: cartesian.y, z: spherical.origin.z), object: longitudeCircleObject)
        let vec = cartesian - spherical.origin
        let scale = simd_length(.init(x: vec.x, y: vec.z))
        SPTScale.update(.init(x: scale, y: scale), object: longitudeCircleObject)
        
    }
    
    private func radiusUpVector(direction: simd_float3) -> simd_float3 {
        // Make sure up and direction vectors are not collinear for correct line orientation
        SPTVector.collinear(direction, .up, tolerance: 0.0001) ? .left : .up
    }
    
    var id: some Hashable {
        Self.keyPath
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
