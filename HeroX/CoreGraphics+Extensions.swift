//
//  CoreGraphics+Extensions.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/18/21.
//

import CoreGraphics
import simd

extension CGSize {
    
    var simd2: SIMD2<Float> {
        SIMD2(x: Float(width), y: Float(height))
    }
    
}

extension CGRect {
    
    var center : CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
}
