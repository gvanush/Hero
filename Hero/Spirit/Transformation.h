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
simd_float3 SPTMakePosition(SPTObject object, float x, float y, float z);
simd_float3 SPTMakePositionZero(SPTObject object);

simd_float3 SPTUpdatePosition(SPTObject object, float x, float y, float z);

simd_float3 SPTGetPosition(SPTObject object);

// MARK: SphericalPosition
typedef struct {
    simd_float3 center;
    float radius;
    float longitude; // relative to z
    float latitude; // relative to y
} SPTSphericalPosition;

SPTSphericalPosition SPTMakeSphericalPosition(SPTObject object, simd_float3 center, float radius, float longitude, float latitude);

void SPTUpdateSphericalPosition(SPTObject object, SPTSphericalPosition pos);

SPTSphericalPosition SPTGetSphericalPosition(SPTObject object);

// MARK: LookAtOrientation
typedef struct {
    simd_float3 target;
    simd_float3 up;
} SPTLookAtOrientation;

SPTLookAtOrientation SPTMakeLookAtOrientation(SPTObject object, simd_float3 target, simd_float3 up);

void SPTUpdateLookAtOrientation(SPTObject object, SPTLookAtOrientation orientation);
    
SPTLookAtOrientation SPTGetLookAtOrientation(SPTObject object);

SPT_EXTERN_C_END
