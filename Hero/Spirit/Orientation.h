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
    SPTOrientationModelEulerXYZ,
    SPTOrientationModelEulerXZY,
    SPTOrientationModelEulerYXZ,
    SPTOrientationModelEulerYZX,
    SPTOrientationModelEulerZXY,
    SPTOrientationModelEulerZYX,
    SPTOrientationModelLookAtPoint,
    SPTOrientationModelLookAtDirection,
    SPTOrientationModelXYAxis,
    SPTOrientationModelYZAxis,
    SPTOrientationModelZXAxis,
} __attribute__((enum_extensibility(closed))) SPTOrientationModel;


// When 'axis' is x, 'up' is used to compute y axis
// When 'axis' is y, 'up' is used to compute z axis
// When 'axis' is z, 'up' is used to compute x axis
typedef struct {
    simd_float3 target;
    simd_float3 up;
    SPTAxis axis;
    bool positive;
} SPTLookAtPointOrientation;

bool SPTLookAtPointOrientationEqual(SPTLookAtPointOrientation lhs, SPTLookAtPointOrientation rhs);

typedef struct {
    simd_float3 normDirection;
    simd_float3 up;
    SPTAxis axis;
    bool positive;
} SPTLookAtDirectionOrientation;

bool SPTLookAtDirectionOrientationEqual(SPTLookAtDirectionOrientation lhs, SPTLookAtDirectionOrientation rhs);

typedef struct {
    simd_float3 orthoNormX;
    simd_float3 orthoNormY;
} SPTXYAxesOrientation;

bool SPTXYAxesOrientationEqual(SPTXYAxesOrientation lhs, SPTXYAxesOrientation rhs);

typedef struct {
    simd_float3 orthoNormY;
    simd_float3 orthoNormZ;
} SPTYZAxesOrientation;

bool SPTYZAxesOrientationEqual(SPTYZAxesOrientation lhs, SPTYZAxesOrientation rhs);

typedef struct {
    simd_float3 orthoNormZ;
    simd_float3 orthoNormX;
} SPTZXAxesOrientation;

bool SPTZXAxesOrientationEqual(SPTZXAxesOrientation lhs, SPTZXAxesOrientation rhs);

typedef struct {
    SPTOrientationModel model;
    union {
        simd_float3 euler;
        SPTLookAtPointOrientation lookAtPoint;
        SPTLookAtDirectionOrientation lookAtDirection;
        SPTXYAxesOrientation xyAxes;
        SPTYZAxesOrientation yzAxes;
        SPTZXAxesOrientation zxAxes;
    };
} SPTOrientation;

bool SPTOrientationEqual(SPTOrientation lhs, SPTOrientation rhs);

void SPTOrientationMake(SPTObject object, SPTOrientation orientation);

void SPTOrientationUpdate(SPTObject object, SPTOrientation orientation);

void SPTOrientationDestroy(SPTObject object);
    
SPTOrientation SPTOrientationGet(SPTObject object);

const SPTOrientation* _Nullable SPTOrientationTryGet(SPTObject object);

bool SPTOrientationExists(SPTObject object);

simd_float3x3 SPTOrientationGetMatrix(SPTOrientation orientation);

SPTOrientation SPTOrientationToEulerXYZ(SPTOrientation orientation);
SPTOrientation SPTOrientationToEulerXZY(SPTOrientation orientation);
SPTOrientation SPTOrientationToEulerYXZ(SPTOrientation orientation);
SPTOrientation SPTOrientationToEulerYZX(SPTOrientation orientation);
SPTOrientation SPTOrientationToEulerZXY(SPTOrientation orientation);
SPTOrientation SPTOrientationToEulerZYX(SPTOrientation orientation);

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
