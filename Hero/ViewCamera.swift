//
//  ViewCamera.swift
//  Hero
//
//  Created by Vanush Grigoryan on 17.05.23.
//

import Foundation


class Object: ObservableObject {
    
    let sptObject: SPTObject
    
    init(sptObject: SPTObject,
         position: SPTPosition = .init(cartesian: .zero),
         orientation: SPTOrientation = .init(eulerXYZ: .zero),
         scale: SPTScale = .init(uniform: 1.0)) {
        self.sptObject = sptObject
        
        SPTPosition.make(position, object: sptObject)
        SPTOrientation.make(orientation, object: sptObject)
        SPTScale.make(scale, object: sptObject)
        
    }
    
    var position: SPTPosition {
        get {
            SPTPosition.get(object: sptObject)
        }
        set {
            objectWillChange.send()
            SPTPosition.update(newValue, object: sptObject)
        }
    }
    
    var orientation: SPTOrientation {
        get {
            SPTOrientation.get(object: sptObject)
        }
        set {
            objectWillChange.send()
            SPTOrientation.update(newValue, object: sptObject)
        }
    }
    
    var scale: SPTScale {
        get {
            SPTScale.get(object: sptObject)
        }
        set {
            objectWillChange.send()
            SPTScale.update(newValue, object: sptObject)
        }
    }
    
    
}

class Camera: Object {
    
    func convertViewportToWorld(point: simd_float3, viewportSize: simd_float2) -> simd_float3 {
        SPTCameraConvertViewportToWorld(sptObject, point, viewportSize)
    }
    
}


class ViewCamera: Camera {
    
    init(sptObject: SPTObject) {
        super.init(sptObject: sptObject, position: Self.initialPosition, orientation: Self.initialOreintation, scale: .init(uniform: 1.0))
        
        SPTCameraMakePerspective(sptObject, Float.pi / 3.0, 1.0, 0.1, 2000.0)
    }
    
    func orbit(deltaAngle: simd_float2) {
        
        var newPosition = position
        newPosition.spherical.latitude -= deltaAngle.y
        newPosition.spherical.longitude -= deltaAngle.x
        position = newPosition
        
        orientation.lookAtPoint.up = Self.up(latitude: newPosition.spherical.latitude)
        
    }
    
    func zoom(deltaY: Float, viewportSize: CGSize) {
        
        var newPosition = position
        
        var viewportPos = SPTCameraConvertWorldToViewport(sptObject, newPosition.spherical.origin, viewportSize.float2);
        viewportPos.y += deltaY
        
        let scenePos = SPTCameraConvertViewportToWorld(sptObject, viewportPos, viewportSize.float2)
        
        let deltaRadius = length(scenePos - newPosition.spherical.origin)
        
        newPosition.spherical.radius = max(newPosition.spherical.radius + sign(deltaY) * deltaRadius, 0.01)
        
        position = newPosition
        
    }
    
    func pan(translation: simd_float2, viewportSize: CGSize) {
        
        var newPosition = position
        var centerViewportPos = SPTCameraConvertWorldToViewport(sptObject, newPosition.spherical.origin, viewportSize.float2);
        
        centerViewportPos.x -= translation.x
        centerViewportPos.y -= translation.y
        
        newPosition.spherical.origin = SPTCameraConvertViewportToWorld(sptObject, centerViewportPos, viewportSize.float2)
        
        position = newPosition
        
        orientation.lookAtPoint.target = newPosition.spherical.origin
        
    }
    
    func focusOn(_ point: simd_float3, animated: Bool) {
        
        var newPosition = position
        
        let initialSin = sign(sinf(newPosition.spherical.latitude))
        
        newPosition = newPosition.toSpherical(origin: point)
        
        if initialSin != sign(sinf(newPosition.spherical.latitude)) {
            // Maintaining same position but with original latitude sign to match with old camera orientation along z axis
            newPosition.spherical.latitude = -newPosition.spherical.latitude
            newPosition.spherical.longitude += Float.pi
        }
        
        position = newPosition
        
        var newOrientation = orientation
        newOrientation.lookAtPoint.up = Self.up(latitude: newPosition.spherical.latitude)
        
        if animated {
            orientation = newOrientation
            SPTOrientationAction.make(lookAtTarget: point, duration: 0.3, easing: .smoothStep, object: sptObject)
        } else {
            newOrientation.lookAtPoint.target = point
            orientation = newOrientation
        }
        
    }
    
    var focusPoint: simd_float3 {
        position.spherical.origin
    }
    
    func reset() {
        position = Self.initialPosition
        orientation = Self.initialOreintation
    }
    
    static func up(latitude: Float) -> simd_float3 {
        sinf(latitude) >= 0.0 ? .up : .down
    }
    
    static let initialPosition = SPTPosition(origin: .zero, radius: 150.0, longitude: 0.25 * Float.pi, latitude: 0.25 * Float.pi)
    static let initialOreintation = SPTOrientation(target: .zero, up: .up, axis: .Z, positive: false)
}
