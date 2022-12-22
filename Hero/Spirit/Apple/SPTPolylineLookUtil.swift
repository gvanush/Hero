//
//  SPTPolylineLookUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.09.22.
//

import Foundation


extension SPTPolylineLook: SPTComponent {
    
    init(color: simd_float4, polylineId: SPTPolylineId, thickness: Float) {
        self.init(color: color, polylineId: polylineId, thickness: thickness, categories: kSPTLookCategoriesAll)
    }
    
    public static func == (lhs: SPTPolylineLook, rhs: SPTPolylineLook) -> Bool {
        SPTPolylineLookEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTPolylineLook, object: SPTObject) {
        SPTPolylineLookMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTPolylineLook, object: SPTObject) {
        if SPTPolylineLookExists(object) {
            SPTPolylineLookUpdate(object, component)
        } else {
            SPTPolylineLookMake(object, component)
        }
    }
    
    static func update(_ component: SPTPolylineLook, object: SPTObject) {
        SPTPolylineLookUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTPolylineLookDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTPolylineLook {
        SPTPolylineLookGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTPolylineLook? {
        SPTPolylineLookTryGet(object)?.pointee
    }
    
}
