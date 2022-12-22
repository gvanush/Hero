//
//  PolylineLookDepthBias.swift
//  Hero
//
//  Created by Vanush Grigoryan on 04.12.22.
//

import Foundation


extension SPTLineLookDepthBias {
    
    static let guideLineLayer1 = SPTLineLookDepthBias(bias: 3.0, slopeScale: 3.0)
    static let guideLineLayer2 = SPTLineLookDepthBias(bias: 6.0, slopeScale: 6.0)
    static let guideLineLayer3 = SPTLineLookDepthBias(bias: 18.0, slopeScale: 9.0)
    
}
