//
//  CoreGraphics+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/18/21.
//

import CoreGraphics
import simd

extension CGSize {
    
    var float2: SIMD2<Float> {
        SIMD2(x: Float(width), y: Float(height))
    }
    
}

extension CGRect {
    
    var center : CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
}

extension CGPoint {
    
    var float2: SIMD2<Float> {
        SIMD2(x: Float(x), y: Float(y))
    }
    
}
