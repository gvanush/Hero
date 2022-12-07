//
//  SPTArcLookUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.12.22.
//

import Foundation


extension SPTArcLook: SPTComponent {
    
    init(color: simd_float4, radius: Float, startAngle: Float, endAngle: Float, thickness: Float) {
        self.init(color: color, radius: radius, startAngle: startAngle, endAngle: endAngle, thickness: thickness, categories: kSPTLookCategoriesAll)
    }
    
    public static func == (lhs: SPTArcLook, rhs: SPTArcLook) -> Bool {
        SPTArcLookEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTArcLook, object: SPTObject) {
        SPTArcLookMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTArcLook, object: SPTObject) {
        if SPTArcLookExists(object) {
            SPTArcLookUpdate(object, component)
        } else {
            SPTArcLookMake(object, component)
        }
    }
    
    static func update(_ component: SPTArcLook, object: SPTObject) {
        SPTArcLookUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTArcLookDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTArcLook {
        SPTArcLookGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTArcLook? {
        SPTArcLookTryGet(object)?.pointee
    }
    
}
