//
//  Matrix.h
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.22.
//

#pragma once

#include "Base.h"
#include "Geometry.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

simd_float3x3 SPTMatrix3x3CreateEulerRotationX(float rx);

simd_float3x3 SPTMatrix3x3CreateEulerRotationY(float ry);

simd_float3x3 SPTMatrix3x3CreateEulerRotationZ(float rz);

simd_float3x3 SPTMatrix3x3CreateOrthonormal(simd_float3 normDirection, SPTAxis axis);


simd_float4x4 SPTMatrix4x4CreateUpperLeft(simd_float3x3 upperLeft);

simd_float3x3 SPTMatrix4x4GetUpperLeft(simd_float4x4 matrix);

SPT_EXTERN_C_END
