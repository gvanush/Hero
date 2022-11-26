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
    SPTOrientationTypeEuler,
    SPTOrientationTypeLookAt,
} __attribute__((enum_extensibility(closed))) SPTOrientationType;

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
    SPTOrientationType type;
    union {
        SPTEulerOrientation euler;
        SPTLookAtOrientation lookAt;
    };
} SPTOrientation;

bool SPTOrientationEqual(SPTOrientation lhs, SPTOrientation rhs);

void SPTOrientationMake(SPTObject object, SPTOrientation orientation);

void SPTOrientationUpdate(SPTObject object, SPTOrientation orientation);

void SPTOrientationDestroy(SPTObject object);
    
SPTOrientation SPTOrientationGet(SPTObject object);

const SPTOrientation* _Nullable SPTOrientationTryGet(SPTObject object);

bool SPTOrientationExists(SPTObject object);

typedef void (* _Nonnull SPTOrientationWillChangeObserver) (SPTOrientation, SPTObserverUserInfo);
SPTObserverToken SPTOrientationAddWillChangeObserver(SPTObject object, SPTOrientationWillChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTOrientationRemoveWillChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTOrientationDidChangeObserver) (SPTOrientation, SPTObserverUserInfo);
SPTObserverToken SPTOrientationAddDidChangeObserver(SPTObject object, SPTOrientationDidChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTOrientationRemoveDidChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTOrientationDidEmergeObserver) (SPTOrientation, SPTObserverUserInfo);
SPTObserverToken SPTOrientationAddDidEmergeObserver(SPTObject object, SPTOrientationDidEmergeObserver observer, SPTObserverUserInfo userInfo);
void SPTOrientationRemoveDidEmergeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTOrientationWillPerishObserver) (SPTObserverUserInfo);
SPTObserverToken SPTOrientationAddWillPerishObserver(SPTObject object, SPTOrientationWillPerishObserver observer, SPTObserverUserInfo userInfo);
void SPTOrientationRemoveWillPerishObserver(SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
