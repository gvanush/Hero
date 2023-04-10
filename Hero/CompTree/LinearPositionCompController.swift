//
//  LinearPositionCompController.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.03.23.
//

import Foundation
import UIKit


class LinearPositionCompController<R>: ObjectCompController<R, SPTLinearCoordinates> {
    
    enum Property: Int, CompProperty {
        case offset
    }
    
    struct Params {
        let sceneViewModel: SceneViewModel
        let origin: SPTObject
        let direction: SPTObject
    }
    
    let params: Params
    @SPTObservedComponent private var position: SPTPosition
    
    private var lineGuideObject: SPTObject!
    private var subscriptions = Set<SPTAnySubscription>()
    
    init(compKeyPath: KeyPath<R, SPTLinearCoordinates>, object: SPTObject, params: Params) {
        
        self.params = params
        _position = .init(object: object)
        
        super.init(compKeyPath: compKeyPath, activeProperty: Property.offset, object: object)
        
        setupOrigin()
        setupDirection()
        setupLine()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(lineGuideObject)
    }
    
    override func onDisclose() {
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointLargeSize, categories: LookCategories.guide.rawValue), object: params.origin)
        SPTPointLook.make(.init(color: UIColor.guide1.rgba, size: .guidePointSmallSize, categories: LookCategories.guide.rawValue), object: params.direction)
        SPTPolylineLook.make(.init(color: UIColor.guide1.rgba, polylineId: params.sceneViewModel.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: lineGuideObject)
    }
    
    override func onClose() {
        SPTPointLook.destroy(object: params.origin)
        SPTPointLook.destroy(object: params.direction)
        SPTPolylineLook.destroy(object: lineGuideObject)
    }
    
    override func onActive() {
        var lineGuideLook = SPTPolylineLook.get(object: lineGuideObject)
        lineGuideLook.color = UIColor.guide1Light.rgba
        SPTPolylineLook.update(lineGuideLook, object: lineGuideObject)
    }
    
    override func onInactive() {
        var lineGuideLook = SPTPolylineLook.get(object: lineGuideObject)
        lineGuideLook.color = UIColor.guide1.rgba
        SPTPolylineLook.update(lineGuideLook, object: lineGuideObject)
    }
    
    private func setupOrigin() {
        SPTPosition.make(.init(cartesian: position.linear.origin), object: params.origin)
        subscriptions.insert(SPTPosition.onWillChangeSink(object: params.origin) { [unowned self] position in
            
            self.position.linear.origin = position.cartesian
            let targetPosition = SPTPosition(cartesian: position.cartesian + self.position.linear.direction)
            SPTPosition.update(targetPosition, object: self.params.direction)
            
            updateLine(originPosition: position, targetPosition: targetPosition)
        })
    }
    
    private func setupDirection() {
        SPTPosition.make(.init(cartesian: position.linear.origin + position.linear.direction), object: params.direction)
        subscriptions.insert(SPTPosition.onWillChangeSink(object: params.direction) { [unowned self] position in
            
            self.position.linear.direction = position.cartesian - self.position.linear.origin
            
            updateLine(originPosition: .init(cartesian: self.position.linear.origin), targetPosition: position)
        })
    }
    
    private func setupLine() {
        let originPosition = SPTPosition.get(object: params.origin)
        let direction = simd_normalize(SPTPosition.get(object: params.direction).cartesian - originPosition.cartesian)
        
        lineGuideObject = params.sceneViewModel.scene.makeObject()
        SPTPosition.make(originPosition, object: lineGuideObject)
        SPTScale.make(.init(x: 500.0), object: lineGuideObject)
        SPTOrientation.make(.init(normDirection: direction, up: lineUpVector(direction: direction), axis: .X), object: lineGuideObject)
        
        SPTLineLookDepthBias.make(.guideLineLayer2, object: lineGuideObject)
    }
    
    private func updateLine(originPosition: SPTPosition, targetPosition: SPTPosition) {
        SPTPosition.update(originPosition, object: lineGuideObject)
        
        let direction = simd_normalize(targetPosition.cartesian - originPosition.cartesian)
        
        var orientation = SPTOrientation.get(object: lineGuideObject)
        orientation.lookAtDirection.normDirection = direction
        orientation.lookAtDirection.up = lineUpVector(direction: direction)
        SPTOrientation.update(orientation, object: lineGuideObject)
    }
    
    private func lineUpVector(direction: simd_float3) -> simd_float3 {
        // Make sure up and direction vectors are not collinear for correct line orientation
        SPTVector.collinear(direction, .up, tolerance: 0.0001) ? .left : .up
    }
    
    func infoFor(_ property: Property) -> ObjectPropertyInfo {
        switch property {
        case .offset:
            return .init(id: compKeyPath.appending(path: \.offset), typeInfo: .float(value: .init(get: {
                self.position.linear.offset
            }, set: {
                self.position.linear.offset = $0
            }), formatter: Formatters.distance), controlTintColor: .primarySelectionColor)
        }
    }
    
}
