//
//  CylindricalPositionAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.12.22.
//

import Foundation


class CylindricalPositionAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    private var radiusLineObject: SPTObject!
    private var heightLineObject: SPTObject!
    private var circleObject: SPTObject!
    private var originObject: SPTObject!
    
    lazy private(set) var radius = AnimatorBindingSetupComponent<CylindricalPositionRadiusAnimatorBindingComponent>(animatableProperty: .cylindricalPositionRadius, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    lazy private(set) var height = AnimatorBindingSetupComponent<CylindricalPositionHeightAnimatorBindingComponent>(animatableProperty: .cylindricalPositionHeight, object: self.object, sceneViewModel: sceneViewModel, parent: self)
        
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
        
        setupGuides()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(radiusLineObject)
        SPTSceneProxy.destroyObject(heightLineObject)
        SPTSceneProxy.destroyObject(circleObject)
        SPTSceneProxy.destroyObject(originObject)
    }
    
    override func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: heightLineObject)
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: circleObject)
        SPTPointLook.make(.init(color: UIColor.inactiveGuideColor.rgba, size: .guidePointLargeSize), object: originObject)
    }
    
    override func onClose() {
        SPTPolylineLook.destroy(object: radiusLineObject)
        SPTPolylineLook.destroy(object: heightLineObject)
        SPTPolylineLook.destroy(object: circleObject)
        SPTPointLook.destroy(object: originObject)
    }
    
    private func setupGuides() {
        
        let cylindricalPosition = SPTPosition.get(object: object).cylindrical
        
        radiusLineObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(.init(cartesian: cylindricalPosition.origin + .init(x: 0.0, y: cylindricalPosition.height, z: 0.0)), object: radiusLineObject)
        SPTScale.make(.init(x: 500.0), object: radiusLineObject)
        SPTOrientation.make(.init(y: cylindricalPosition.longitude - 0.5 * Float.pi), object: radiusLineObject)
        
        heightLineObject = sceneViewModel.scene.makeObject()
        var heightLinePosition = SPTPosition.get(object: object)
        heightLinePosition.cylindrical.height = 0.0
        SPTPosition.make(heightLinePosition, object: heightLineObject)
        SPTScale.make(.init(x: 500.0), object: heightLineObject)
        SPTOrientation.make(.init(z: 0.5 * Float.pi), object: heightLineObject)
        
        let circleOriginPosition = SPTPosition(cartesian: .init(x: cylindricalPosition.origin.x, y: cylindricalPosition.height, z: cylindricalPosition.origin.z))
        circleObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(circleOriginPosition, object: circleObject)
        SPTScale.make(.init(x: cylindricalPosition.radius, y: cylindricalPosition.radius), object: circleObject)
        SPTOrientation.make(.init(x: 0.5 * Float.pi), object: circleObject)
        
        originObject = sceneViewModel.scene.makeObject()
        SPTPosition.make(circleOriginPosition, object: originObject)
    }
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [radius, height] }
    
}


class CylindricalPositionRadiusAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard animatableProperty == .cylindricalPositionRadius && position.coordinateSystem == .cylindrical else {
            fatalError()
        }
        
        let cartesian = position.cylindrical.toCartesian

        let axisDirection = simd_float3(x: cartesian.x - position.cylindrical.origin.x, y: 0.0, z: cartesian.z - position.cylindrical.origin.z)
        super.init(axisDirection: axisDirection, editingParamsKeyPath: \.[cylindricalPositionBindingOf: object].radius, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
    }
    
}

class CylindricalPositionHeightAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard animatableProperty == .cylindricalPositionHeight && position.coordinateSystem == .cylindrical else {
            fatalError()
        }

        super.init(axisDirection: .up, editingParamsKeyPath: \.[cylindricalPositionBindingOf: object].height, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
    }
    
}
