//
//  SPTVectorUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.22.
//

import Foundation


enum SPTVector {
    
    static func radiansToDegrees(_ radians: simd_float3) -> simd_float3 {
        SPTVectorRadiansToDegrees(radians)
    }
    
    static func degreesToRadians(_ degrees: simd_float3) -> simd_float3 {
        SPTVectorDegreesToRadians(degrees)
    }
 
    static func maxComponentIndex(_ vec: simd_float3) -> Int {
        Int(SPTVectorMaxComponentIndex(vec))
    }
    
    static func minComponentIndex(_ vec: simd_float3) -> Int {
        Int(SPTVectorMinComponentIndex(vec))
    }
    
    static func createOrthogonal(_ vec: simd_float3) -> simd_float3 {
        SPTVectorCreateOrthogonal(vec)
    }
    
    static func collinear(_ vec1: simd_float3, _ vec2: simd_float3, tolerance: Float) -> Bool {
        SPTVectorCollinear(vec1, vec2, tolerance)
    }
    
}

extension simd_float3 {
    
    var minComponent: Float {
        SPTVectorMinComponent(self)
    }
    
    var maxComponent: Float {
        SPTVectorMaxComponent(self)
    }
    
}

extension simd_float4 {
    
    var xyz: simd_float3 {
        .init(x: x, y: y, z: z)
    }
    
}
