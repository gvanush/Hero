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

void SPTOrientationDestroy(SPTObject object);
    
SPTOrientation SPTOrientationGet(SPTObject object);

const SPTOrientation* _Nullable SPTOrientationTryGet(SPTObject object);

bool SPTOrientationExists(SPTObject object);

typedef void (* _Nonnull SPTOrientationWillChangeObserver) (SPTOrientation, SPTComponentObserverUserInfo);
SPTObserverToken SPTOrientationAddWillChangeObserver(SPTObject object, SPTOrientationWillChangeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTOrientationRemoveWillChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTOrientationWillEmergeObserver) (SPTOrientation, SPTComponentObserverUserInfo);
SPTObserverToken SPTOrientationAddWillEmergeObserver(SPTObject object, SPTOrientationWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTOrientationRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTOrientationWillPerishObserver) (SPTComponentObserverUserInfo);
SPTObserverToken SPTOrientationAddWillPerishObserver(SPTObject object, SPTOrientationWillPerishObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTOrientationRemoveWillPerishObserver(SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
