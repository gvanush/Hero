//
//  SPTOutlineLookUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.09.22.
//

import Foundation


extension SPTOutlineLook: SPTComponent {
    
    init(color: simd_float4, thickness: Float) {
        self.init(color: color, thickness: thickness, categories: kSPTLookCategoriesAll)
    }
    
    public static func == (lhs: SPTOutlineLook, rhs: SPTOutlineLook) -> Bool {
        SPTOutlineLookEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTOutlineLook, object: SPTObject) {
        SPTOutlineLookMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTOutlineLook, object: SPTObject) {
        if SPTOutlineLookExists(object) {
            SPTOutlineLookUpdate(object, component)
        } else {
            SPTOutlineLookMake(object, component)
        }
    }
    
    static func update(_ component: SPTOutlineLook, object: SPTObject) {
        SPTOutlineLookUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTOutlineLookDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTOutlineLook {
        SPTOutlineLookGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTOutlineLook? {
        SPTOutlineLookTryGet(object)?.pointee
    }
}
