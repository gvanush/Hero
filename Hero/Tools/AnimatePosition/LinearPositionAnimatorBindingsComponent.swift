//
//  LinearPositionAnimatorBindingsComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.22.
//

import SwiftUI


class LinearPositionAnimatorBindingsComponent: Component {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    lazy private(set) var offset = AnimatorBindingSetupComponent<LinearPositionOffsetAnimatorBindingComponent>(animatableProperty: .linearPositionOffset, object: self.object, sceneViewModel: sceneViewModel, parent: self)
    
    private var originGuideObject: SPTObject!
    private var lineGuideObject: SPTObject!
    
    required init(object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        super.init(parent: parent)
        
        setupGuides()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(originGuideObject)
        SPTSceneProxy.destroyObject(lineGuideObject)
    }
    
    override func onDisclose() {
        SPTPolylineLook.make(.init(color: UIColor.inactiveGuideColor.rgba, polylineId: sceneViewModel.lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: lineGuideObject)
        SPTPointLook.make(.init(color: UIColor.inactiveGuideColor.rgba, size: .guidePointLargeSize), object: originGuideObject)
    }
    
    override func onClose() {
        SPTPolylineLook.destroy(object: lineGuideObject)
        SPTPointLook.destroy(object: originGuideObject)
    }
    
    private func setupGuides() {
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
    
    override var title: String {
        "Animators"
    }
    
    override var subcomponents: [Component]? { [offset] }
    
}


class LinearPositionOffsetAnimatorBindingComponent: ObjectDistanceAnimatorBindingComponent, AnimatorBindingComponentProtocol {
    
    required init(animatableProperty: SPTAnimatableObjectProperty, object: SPTObject, sceneViewModel: SceneViewModel, parent: Component?) {
        
        let position = SPTPosition.get(object: object)
        
        guard animatableProperty == .linearPositionOffset && position.coordinateSystem == .linear else {
            fatalError()
        }

        super.init(normAxisDirection: simd_normalize(position.linear.direction), editingParamsKeyPath: \.[linearPositionBindingOf: object].offset, animatableProperty: animatableProperty, object: object, sceneViewModel: sceneViewModel, parent: parent)
    }
    
}
