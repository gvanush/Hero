//
//  Matrix.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.22.
//

#include "Matrix.h"

#include "Vector.h"

simd_float3x3 SPTMatrix3x3CreateEulerRotationX(float rx) {
    const auto c = cosf(rx);
    const auto s = sinf(rx);
    return simd_float3x3 {
        simd_float3 {1.f, 0.f, 0.f},
        simd_float3 {0.f, c, s},
        simd_float3 {0.f, -s, c}
    };
}

simd_float3x3 SPTMatrix3x3CreateEulerRotationY(float ry) {
    const auto c = cosf(ry);
    const auto s = sinf(ry);
    return simd_float3x3 {
        simd_float3 {c, 0.f, -s},
        simd_float3 {0.f, 1.f, 0.f},
        simd_float3 {s, 0.f, c}
    };
}

simd_float3x3 SPTMatrix3x3CreateEulerRotationZ(float rz) {
    const auto c = cosf(rz);
    const auto s = sinf(rz);
    return simd_float3x3 {
        simd_float3 {c, s, 0.f},
        simd_float3 {-s, c, 0.f},
        simd_float3 {0.f, 0.f, 1.f},
    };
}

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
