//
//  Transformation.h
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "Base.h"
#include "Geometry.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

// MARK: Position
simd_float3 SPTMakePosition(SPTObject object, float x, float y, float z);
simd_float3 SPTMakePositionZero(SPTObject object);

void SPTUpdatePosition(SPTObject object, simd_float3 position);

simd_float3 SPTGetPosition(SPTObject object);

void SPTAddPositionWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemovePositionWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemovePositionWillChangeListener(SPTObject object, SPTComponentListener listener);

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

simd_float3 SPTGetPositionFromSphericalPosition(SPTSphericalPosition sphericalPosition);


// MARK: Scale
simd_float3 SPTMakeScale(SPTObject object, float x, float y, float z);

void SPTUpdateScale(SPTObject object, simd_float3 scale);

simd_float3 SPTGetScale(SPTObject object);

void SPTAddScaleWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveScaleWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveScaleWillChangeListener(SPTObject object, SPTComponentListener listener);

SPT_EXTERN_C_END
