//
//  ActionUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.12.22.
//

import Foundation


enum SPTPositionAction {
    
    static func make(position: SPTPosition, duration: Double, easing: SPTEasingType, object: SPTObject) {
        SPTPositionActionMake(object, position, duration, easing)
    }
    
    static func exists(object: SPTObject) {
        SPTPositionActionExists(object)
    }
    
    static func destroy(object: SPTObject) {
        SPTPositionActionDestroy(object)
    }
    
}


enum SPTOrientationAction {
    
    static func make(lookAtTarget target: simd_float3, duration: Double, easing: SPTEasingType, object: SPTObject) {
        SPTOrientationActionMakeLookAtTarget(object, target, duration, easing)
    }
    
    static func exists(object: SPTObject) {
        SPTOrientationActionExists(object)
    }
    
    static func destroy(object: SPTObject) {
        SPTOrientationActionDestroy(object)
    }
    
}
