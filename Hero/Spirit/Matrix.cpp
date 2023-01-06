//
//  Matrix.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.22.
//

#include "Matrix.h"

#include "Vector.h"

simd_float3x3 SPTMatrix3x3CreateOrthonormal(simd_float3 normDirection, SPTAxis axis) {
    
    const simd_float3 ortho1 = simd_normalize(SPTVectorCreateOrthogonal(normDirection));
    const simd_float3 ortho2 = simd_normalize(simd_cross(normDirection, ortho1));
    
    // Making sure that right handedness is preserved
    switch (axis) {
        case SPTAxisX:
            return simd_float3x3 {
                normDirection,
                ortho1,
                ortho2,
            };
            
        case SPTAxisY:
            return simd_float3x3 {
                ortho2,
                normDirection,
                ortho1
            };
            
        case SPTAxisZ:
            return simd_float3x3 {
                ortho1,
                ortho2,
                normDirection
            };
    }
    
}

simd_float4x4 SPTMatrix4x4CreateUpperLeft(simd_float3x3 upperLeft) {
    return simd_float4x4 {
        simd_make_float4(upperLeft.columns[0], 0.f),
        simd_make_float4(upperLeft.columns[1], 0.f),
        simd_make_float4(upperLeft.columns[2], 0.f),
        {0.f, 0.f, 0.f, 1.f}
    };
}

simd_float3x3 SPTMatrix4x4GetUpperLeft(simd_float4x4 matrix) {
    return simd_float3x3 {
        simd_make_float3(matrix.columns[0]),
        simd_make_float3(matrix.columns[1]),
        simd_make_float3(matrix.columns[2]),
    };
}
