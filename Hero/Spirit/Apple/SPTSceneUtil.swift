//
//  SPTSceneUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.09.22.
//

import Foundation


class SPTSceneProxy {
    
    let handle: SPTHandle
    
    init() {
        self.handle = SPTSceneMake()
    }
    
    deinit {
        SPTSceneDestroy(handle)
    }
    
    func makeObject() -> SPTObject {
        SPTSceneMakeObject(handle)
    }
    
    static func destroyObject(_ object: SPTObject) {
        SPTSceneDestroyObject(object)
    }
    
}
