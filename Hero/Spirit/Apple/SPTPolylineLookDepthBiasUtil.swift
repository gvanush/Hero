//
//  SPTLineLookDepthBiasUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.12.22.
//

import Foundation


extension SPTLineLookDepthBias {
    
    init(bias: Float, slopeScale: Float) {
        self.init(bias: bias, slopeScale: slopeScale, clamp: 0.0)
    }
    
    static func make(_ component: SPTLineLookDepthBias, object: SPTObject) {
        SPTLineLookDepthBiasMake(object, component)
    }
    
}
