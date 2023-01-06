//
//  SPTMatrixUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.22.
//

import Foundation


enum SPTMatrix3x3 {

    static func createOrthonormal(normDirection: simd_float3, axis: SPTAxis) -> simd_float3x3 {
        SPTMatrix3x3CreateOrthonormal(normDirection, axis)
    }
    
}

enum SPTMatrix4x4 {
    
    static func create(upperLeft: simd_float3x3) -> simd_float4x4 {
        SPTMatrix4x4CreateUpperLeft(upperLeft)
    }
    
}
