//
//  SPTPointLookUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.09.22.
//

import Foundation


extension SPTPointLook: SPTComponent {
    
    init(color: simd_float4, size: Float) {
        self.init(color: color, size: size, categories: kSPTLookCategoriesAll)
    }
    
    public static func == (lhs: SPTPointLook, rhs: SPTPointLook) -> Bool {
        SPTPointLookEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTPointLook, object: SPTObject) {
        SPTPointLookMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTPointLook, object: SPTObject) {
        if SPTPointLookExists(object) {
            SPTPointLookUpdate(object, component)
        } else {
            SPTPointLookMake(object, component)
        }
    }
    
    static func update(_ component: SPTPointLook, object: SPTObject) {
        SPTPointLookUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTPointLookDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTPointLook {
        SPTPointLookGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTPointLook? {
        SPTPointLookTryGet(object)?.pointee
    }
}
