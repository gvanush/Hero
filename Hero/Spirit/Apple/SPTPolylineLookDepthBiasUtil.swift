//
//  SPTPolylineLookDepthBiasUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.12.22.
//

import Foundation


extension SPTPolylineLookDepthBias {
    
    init(bias: Float, slopeScale: Float) {
        self.init(bias: bias, slopeScale: slopeScale, clamp: 0.0)
    }
    
    static func make(_ component: SPTPolylineLookDepthBias, object: SPTObject) {
        SPTPolylineLookDepthBiasMake(object, component)
    }
    
}
