//
//  Orientation.h
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#pragma once

#include "Base.h"
#include "Geometry.h"

#include <simd/simd.h>


SPT_EXTERN_C_BEGIN

typedef enum {
    SPTOrientationVariantTagEuler,
    SPTOrientationVariantTagLookAt,
} __attribute__((enum_extensibility(closed))) SPTOrientationVariantTag;

typedef enum {
    SPTEulerOrderXYZ,
    SPTEulerOrderXZY,
    SPTEulerOrderYXZ,
    SPTEulerOrderYZX,
    SPTEulerOrderZXY,
    SPTEulerOrderZYX
} __attribute__((enum_extensibility(closed))) SPTEulerOrder;

typedef struct {
    simd_float3 rotation;
    SPTEulerOrder order;
} SPTEulerOrientation;

bool SPTEulerOrientationEqual(SPTEulerOrientation lhs, SPTEulerOrientation rhs);

// When 'axis' is x, 'up' is used to compute y axis
// When 'axis' is y, 'up' is used to compute z axis
// When 'axis' is z, 'up' is used to compute x axis
typedef struct {
    simd_float3 target;
    simd_float3 up;
    SPTAxis axis;
    bool positive;
} SPTLookAtOrientation;

bool SPTLookAtOrientationEqual(SPTLookAtOrientation lhs, SPTLookAtOrientation rhs);

typedef struct {
    SPTOrientationVariantTag variantTag;
    union {
        SPTEulerOrientation euler;
        SPTLookAtOrientation lookAt;
    };
} SPTOrientation;

bool SPTOrientationEqual(SPTOrientation lhs, SPTOrientation rhs);

void SPTOrientationMake(SPTObject object, SPTOrientation orientation);
void SPTOrientationMakeEuler(SPTObject object, SPTEulerOrientation euler);
void SPTOrientationMakeLookAt(SPTObject object, SPTLookAtOrientation lookAt);

void SPTOrientationUpdate(SPTObject object, SPTOrientation orientation);
    
SPTOrientation SPTOrientationGet(SPTObject object);

typedef void (*SPTOrientationWillChangeCallback) (SPTComponentListener, SPTOrientation);
void SPTOrientationAddWillChangeListener(SPTObject object, SPTComponentListener listener, SPTOrientationWillChangeCallback callback);
void SPTOrientationRemoveWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTOrientationWillChangeCallback callback);
void SPTOrientationRemoveWillChangeListener(SPTObject object, SPTComponentListener listener);

SPT_EXTERN_C_END
