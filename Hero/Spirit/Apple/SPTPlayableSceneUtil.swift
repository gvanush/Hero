//
//  SPTPlayableSceneUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.09.22.
//

import Foundation


class SPTPlayableSceneProxy {
    
    let handle: SPTHandle
    
    init(scene: SPTSceneProxy, viewCameraEntity: SPTEntity) {
        handle = SPTPlayableSceneMake(scene.handle, viewCameraEntity)
    }
    
    deinit {
        SPTPlayableSceneDestroy(handle)
    }
    
    var params: SPTPlayableSceneParams {
        SPTPlayableSceneGetParams(handle)
    }
}
