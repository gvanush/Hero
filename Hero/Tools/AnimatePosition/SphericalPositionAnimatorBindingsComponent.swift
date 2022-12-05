//
//  SphericalPositionAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.12.22.
//

import Foundation


class SphericalPositionAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    private var radiusLineObject: SPTObject!
    private var latitudeCircleObject: SPTObject!
    private var longitudeCircleObject: SPTObject!
    private var originObject: SPTObject!
    
    lazy private(set) var radius = AnimatorBindingSetupComponent<SphericalPositionRadiusAnimatorBindingComponent>(animatableProperty: .sphericalPositionRadius, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
        
        setupGuides()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(radiusLineObject)
        SPTSceneProxy.destroyObject(latitudeCircleObject)
        SPTSceneProxy.destroyObject(longitudeCircleObject)
        SPTSceneProxy.destroyObject(originObject)
    }
    
    override func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: latitudeCircleObject)
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: longitudeCircleObject)
        SPTPointLook.make(.init(color: UIColor.inactiveGuideColor.rgba, size: .guidePointLargeSize), object: originObject)
    }
    
    override func onClose() {
        SPTPolylineLook.destroy(object: radiusLineObject)
        SPTPolylineLook.destroy(object: latitudeCircleObject)
        SPTPolylineLook.destroy(object: longitudeCircleObject)
        SPTPointLook.destroy(object: originObject)
    }
    
    private func setupGuides() {
        
        let sphericalPosition = SPTPosition.get(object: object).spherical
        let objectCartesian = sphericalPosition.toCartesian
        let radiusDirection = objectCartesian - sphericalPosition.origin
        let radiusNormDirection = simd_normalize(radiusDirection)
        
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: sphericalPosition.origin), object: radiusLineObject)
        SPTScale.make(.init(x: 500.0), object: radiusLineObject)

        // Make sure up and direction vectors are not collinear for correct line orientation
        let radiusUpVector: simd_float3 = SPTCollinear(radiusNormDirection, .up, 0.0001) ? .left : .up
        SPTOrientation.make(.init(normDirection: radiusNormDirection, up: radiusUpVector, axis: .X), object: radiusLineObject)
        
        latitudeCircleObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: sphericalPosition.origin), object: latitudeCircleObject)
        SPTScale.make(.init(x: sphericalPosition.radius, y: sphericalPosition.radius), object: latitudeCircleObject)
        SPTOrientation.make(.init(y: 0.5 * Float.pi + sphericalPosition.longitude), object: latitudeCircleObject)
        
        longitudeCircleObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: .init(x: sphericalPosition.origin.x, y: objectCartesian.y, z: sphericalPosition.origin.z)), object: longitudeCircleObject)
        
        let scale = simd_length(.init(x: radiusDirection.x, y: radiusDirection.z))
        SPTScale.make(.init(x: scale, y: scale), object: longitudeCircleObject)
        SPTOrientation.make(.init(x: 0.5 * Float.pi), object: longitudeCircleObject)
        
        originObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: sphericalPosition.origin), object: originObject)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [radius] }
    
}


class SphericalPositionRadiusAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard animatableProperty == .sphericalPositionRadius && position.coordinateSystem == .spherical else {
            fatalError()
        }
        
        let cartesian = position.spherical.toCartesian

        super.init(axisDirection: cartesian - position.spherical.origin, editingParamsKeyPath: \.[sphericalPositionBindingOf: object].radius, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
    }
    
}
