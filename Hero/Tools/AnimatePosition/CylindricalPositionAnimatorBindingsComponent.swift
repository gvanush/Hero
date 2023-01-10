//
//  CylindricalPositionAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.12.22.
//

import Foundation
import SwiftUI


class CylindricalPositionAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    private var radiusLineObject: SPTObject!
    private var heightLineObject: SPTObject!
    private var circleObject: SPTObject!
    private var circleCenterObject: SPTObject!
    
    lazy private(set) var longitude = AnimatorBindingSetupComponent<CylindricalPositionLongitudetAnimatorBindingComponent>(animatableProperty: .cylindricalPositionLongitude, defaultValueAt0: -0.25 * .pi, defaultValueAt1: 0.25 * .pi, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    lazy private(set) var radius = AnimatorBindingSetupComponent<CylindricalPositionRadiusAnimatorBindingComponent>(animatableProperty: .cylindricalPositionRadius, defaultValueAt0: -5.0, defaultValueAt1: 5.0, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    lazy private(set) var height = AnimatorBindingSetupComponent<CylindricalPositionHeightAnimatorBindingComponent>(animatableProperty: .cylindricalPositionHeight, defaultValueAt0: -5.0, defaultValueAt1: 5.0, object: self.object, sceneViewModel: sceneViewModel, parent: self)
        
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
        SPTSceneProxy.destroyObject(circleCenterObject)
    }
    
    override func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: radiusLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide2.rgba, polylineId: sceneViewModel.yAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: heightLineObject)
        SPTPolylineLook.make(.init(color: UIColor.guide3.rgba, polylineId: sceneViewModel.circleOutlineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: circleObject)
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointSmallSize), object: circleCenterObject)
    }
    
    override func onClose() {
        SPTPolylineLook.destroy(object: radiusLineObject)
        SPTPolylineLook.destroy(object: heightLineObject)
        SPTPolylineLook.destroy(object: circleObject)
        SPTPointLook.destroy(object: circleCenterObject)
    }
    
    private func setupGuides() {
        
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
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [radius, height, longitude] }
    
}


class CylindricalPositionRadiusAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard animatableProperty == .cylindricalPositionRadius && position.coordinateSystem == .cylindrical else {
            fatalError()
        }
        
        let cartesian = position.cylindrical.toCartesian

        let axisDirection = (position.cylindrical.radius.sign == .plus ? 1.0 : -1.0) * simd_normalize(simd_float3(x: cartesian.x - position.cylindrical.origin.x, y: 0.0, z: cartesian.z - position.cylindrical.origin.z))
        super.init(normAxisDirection: axisDirection, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
    }

}

class CylindricalPositionHeightAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard animatableProperty == .cylindricalPositionHeight && position.coordinateSystem == .cylindrical else {
            fatalError()
        }

        super.init(normAxisDirection: .up, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        guideColor = .guide2Dark
        selectedGuideColor = .guide2Light
    }
    
}

class CylindricalPositionLongitudetAnimatorBindingComponent: ObjectAngleAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard animatableProperty == .cylindricalPositionLongitude && position.coordinateSystem == .cylindrical else {
            fatalError()
        }

        super.init(origin: .init(x: position.cylindrical.origin.x, y: position.cylindrical.origin.y + position.cylindrical.height, z: position.cylindrical.origin.z), normRotationAxis: .up, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
        
        guideColor = .guide3Dark
        selectedGuideColor = .guide3Light
    }
    
}
