//
//  SPTPlayableSceneUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.09.22.
//

import Foundation


class SPTPlayableSceneProxy: Identifiable {
    
    let handle: SPTHandle
    
    init(scene: SPTSceneProxy, viewCameraEntity: SPTEntity, animators: [SPTAnimatorId]? = nil) {
        var descriptor = SPTPlayableSceneDescriptor()
        descriptor.viewCameraEntity = viewCameraEntity
        if let animators = animators {
            handle = animators.withUnsafeBufferPointer({ bufferPtr in
                descriptor.animators = bufferPtr.baseAddress!
                descriptor.animatorsSize = UInt32(bufferPtr.count)
                return SPTPlayableSceneMake(scene.handle, descriptor)
            })
        } else {
            descriptor.animators = nil
            descriptor.animatorsSize = 0
            handle = SPTPlayableSceneMake(scene.handle, descriptor)
        }
        
    }
    
    deinit {
        SPTPlayableSceneDestroy(handle)
    }
    
    var params: SPTPlayableSceneParams {
        SPTPlayableSceneGetParams(handle)
    }
}
