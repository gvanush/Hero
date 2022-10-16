//
//  SPTPlayableSceneUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.09.22.
//

import Foundation


class SPTPlayableSceneProxy: Identifiable {
    
    let handle: SPTHandle
    
    init(scene: SPTSceneProxy, viewCameraEntity: SPTEntity, animatorIds: [SPTAnimatorId]? = nil) {
        var descriptor = SPTPlayableSceneDescriptor()
        descriptor.viewCameraEntity = viewCameraEntity
        if let animatorIds = animatorIds {
            handle = animatorIds.withUnsafeBufferPointer({ bufferPtr in
                descriptor.animatorIds = bufferPtr.baseAddress!
                descriptor.animatorsSize = UInt32(bufferPtr.count)
                return SPTPlayableSceneMake(scene.handle, descriptor)
            })
        } else {
            descriptor.animatorIds = nil
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
