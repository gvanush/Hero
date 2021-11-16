//
//  Transformation.h
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

// MARK: Position
typedef struct {
    simd_float3 float3;
} SPTPosition;

simd_float3 SPTMakePositionZero(SPTObject entity);
simd_float3 SPTMakePosition(SPTObject entity, float x, float y, float z);

simd_float3 SPTUpdatePosition(SPTObject entity, float x, float y, float z);

simd_float3 SPTGetPosition(SPTObject entity);

// MARK: SphericalPosition
typedef struct {
    simd_float3 center;
    float radius;
    float longitude; // relative to z
    float latitude; // relative to y
} SPTSphericalPosition;

// MARK: LookAtOrientation
typedef struct {
    simd_float3 target;
} LookAtOrientation;

SPT_EXTERN_C_END
