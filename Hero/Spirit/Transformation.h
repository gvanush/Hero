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

void SPTAddPositionListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemovePositionListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemovePositionListener(SPTObject object, SPTComponentListener listener);

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

// MARK: EulerOrientation
typedef enum {
    SPTEulerOrderXYZ,
    SPTEulerOrderXZY,
    SPTEulerOrderYXZ,
    SPTEulerOrderYZX,
    SPTEulerOrderZXY,
    SPTEulerOrderZYX
} SPTEulerOrder;

typedef struct {
    simd_float3 rotation;
    SPTEulerOrder order;
} SPTEulerOrientation;

SPTEulerOrientation SPTMakeEulerOrientation(SPTObject object, simd_float3 rotation, SPTEulerOrder order);

void SPTUpdateEulerOrientation(SPTObject object, SPTEulerOrientation orientation);
void SPTUpdateEulerOrientationRotation(SPTObject object, simd_float3 rotation);
    
SPTEulerOrientation SPTGetEulerOrientation(SPTObject object);

void SPTAddEulerOrientationListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveEulerOrientationListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveEulerOrientationListener(SPTObject object, SPTComponentListener listener);

// MARK: LookAtOrientation
typedef enum {
    SPTLookAtAxisPositiveX,
    SPTLookAtAxisNegativeX,
    SPTLookAtAxisPositiveY,
    SPTLookAtAxisNegativeY,
    SPTLookAtAxisPositiveZ,
    SPTLookAtAxisNegativeZ
} SPTLookAtAxis;

// When 'axis' is x, 'up' is used to compute y axis
// When 'axis' is y, 'up' is used to compute z axis
// When 'axis' is z, 'up' is used to compute x axis
typedef struct {
    simd_float3 target;
    simd_float3 up;
    SPTAxis axis;
    bool positive;
} SPTLookAtOrientation;

SPTLookAtOrientation SPTMakeLookAtOrientation(SPTObject object, simd_float3 target, SPTAxis axis, bool positive, simd_float3 up);

void SPTUpdateLookAtOrientation(SPTObject object, SPTLookAtOrientation orientation);
    
SPTLookAtOrientation SPTGetLookAtOrientation(SPTObject object);

// MARK: Scale
simd_float3 SPTMakeScale(SPTObject object, float x, float y, float z);

void SPTUpdateScale(SPTObject object, simd_float3 scale);

simd_float3 SPTGetScale(SPTObject object);

void SPTAddScaleListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveScaleListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveScaleListener(SPTObject object, SPTComponentListener listener);

SPT_EXTERN_C_END
