//
//  Matrix+Orientation.h
//  Hero
//
//  Created by Vanush Grigoryan on 06.01.23.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

simd_float3x3 SPTMatrix3x3CreateEulerXOrientation(float rx);

simd_float3x3 SPTMatrix3x3CreateEulerYOrientation(float ry);

simd_float3x3 SPTMatrix3x3CreateEulerZOrientation(float rz);


simd_float3x3 SPTMatrix3x3CreateEulerXYZOrientation(simd_float3 angles);

simd_float3x3 SPTMatrix3x3CreateEulerXZYOrientation(simd_float3 angles);

simd_float3x3 SPTMatrix3x3CreateEulerYXZOrientation(simd_float3 angles);

simd_float3x3 SPTMatrix3x3CreateEulerYZXOrientation(simd_float3 angles);

simd_float3x3 SPTMatrix3x3CreateEulerZXYOrientation(simd_float3 angles);

simd_float3x3 SPTMatrix3x3CreateEulerZYXOrientation(simd_float3 angles);


simd_float3x3 SPTMatrix3x3CreateVectorToVector(simd_float3 normVec, simd_float3 normTargetVec);


simd_float3 SPTMatrix3x3GetEulerXYZOrientationAngles(simd_float3x3 matrix);

simd_float3 SPTMatrix3x3GetEulerXZYOrientationAngles(simd_float3x3 matrix);

simd_float3 SPTMatrix3x3GetEulerYXZOrientationAngles(simd_float3x3 matrix);

simd_float3 SPTMatrix3x3GetEulerYZXOrientationAngles(simd_float3x3 matrix);

simd_float3 SPTMatrix3x3GetEulerZXYOrientationAngles(simd_float3x3 matrix);

simd_float3 SPTMatrix3x3GetEulerZYXOrientationAngles(simd_float3x3 matrix);



SPT_EXTERN_C_END
