//
//  SPTOrientationMatrixUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.01.23.
//

import Foundation


enum SPTOrientationMatrix3x3 {
    
    static func createEulerXOrientation(_ rx: Float) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerXOrientation(rx)
    }
    
    static func createEulerYOrientation(_ ry: Float) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerYOrientation(ry)
    }
    
    static func createEulerZOrientation(_ rz: Float) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerZOrientation(rz)
    }
    
    
    static func createEulerXYZOrientation(_ angles: simd_float3) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerXYZOrientation(angles)
    }
    
    static func createEulerXZYOrientation(_ angles: simd_float3) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerXZYOrientation(angles)
    }
    
    static func createEulerYXZOrientation(_ angles: simd_float3) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerYXZOrientation(angles)
    }
    
    static func createEulerYZXOrientation(_ angles: simd_float3) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerYZXOrientation(angles)
    }
    
    static func createEulerZXYOrientation(_ angles: simd_float3) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerZXYOrientation(angles)
    }
    
    static func createEulerZYXOrientation(_ angles: simd_float3) -> simd_float3x3 {
        SPTMatrix3x3CreateEulerZYXOrientation(angles)
    }
    
    
    static func getEulerXYZOrientationAngles(_ matrix: simd_float3x3) -> simd_float3 {
        SPTMatrix3x3GetEulerXYZOrientationAngles(matrix)
    }
    
    static func getEulerXZYOrientationAngles(_ matrix: simd_float3x3) -> simd_float3 {
        SPTMatrix3x3GetEulerXZYOrientationAngles(matrix)
    }
    
    static func getEulerYXZOrientationAngles(_ matrix: simd_float3x3) -> simd_float3 {
        SPTMatrix3x3GetEulerYXZOrientationAngles(matrix)
    }
    
    static func getEulerYZXOrientationAngles(_ matrix: simd_float3x3) -> simd_float3 {
        SPTMatrix3x3GetEulerYZXOrientationAngles(matrix)
    }
    
    static func getEulerZXYOrientationAngles(_ matrix: simd_float3x3) -> simd_float3 {
        SPTMatrix3x3GetEulerZXYOrientationAngles(matrix)
    }
    
    static func getEulerZYXOrientationAngles(_ matrix: simd_float3x3) -> simd_float3 {
        SPTMatrix3x3GetEulerZYXOrientationAngles(matrix)
    }
}
