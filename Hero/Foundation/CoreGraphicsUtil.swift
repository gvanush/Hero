//
//  CGFloatUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.01.22.
//

import Foundation
import CoreGraphics
import simd


extension CGFloat {
    
    static var objectSelectionBorderWidth: Self {
        1.0
    }
    
}


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

