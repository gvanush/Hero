//
//  Position.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTPositionVariantTagXYZ,
    SPTPositionVariantTagSpherical,
} __attribute__((enum_extensibility(closed))) SPTPositionVariantTag;

typedef struct {
    simd_float3 center;
    float radius;
    float longitude; // relative to z
    float latitude; // relative to y
} SPTSphericalPosition;

bool SPTSphericalPositionEqual(SPTSphericalPosition lhs, SPTSphericalPosition rhs);

typedef struct {
    SPTPositionVariantTag variantTag;
    union {
        simd_float3 xyz;
        SPTSphericalPosition spherical;
    };
} SPTPosition;

bool SPTPositionEqual(SPTPosition lhs, SPTPosition rhs);

void SPTPositionMake(SPTObject object, SPTPosition position);
void SPTPositionMakeXYZ(SPTObject object, simd_float3 xyz);
void SPTPositionMakeSpherical(SPTObject object, SPTSphericalPosition spherical);

void SPTPositionUpdate(SPTObject object, SPTPosition position);

void SPTPositionDestroy(SPTObject object);

SPTPosition SPTPositionGet(SPTObject object);
simd_float3 SPTPositionGetXYZ(SPTObject object);

const SPTPosition* _Nullable SPTPositionTryGet(SPTObject object);

bool SPTPositionExists(SPTObject object);

simd_float3 SPTPositionConvertSphericalToXYZ(SPTSphericalPosition sphericalPosition);

typedef void (* _Nonnull SPTPositionWillChangeObserver) (SPTPosition, SPTObserverUserInfo);
SPTObserverToken SPTPositionAddWillChangeObserver(SPTObject object, SPTPositionWillChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTPositionRemoveWillChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTPositionWillEmergeObserver) (SPTPosition, SPTObserverUserInfo);
SPTObserverToken SPTPositionAddWillEmergeObserver(SPTObject object, SPTPositionWillEmergeObserver observer, SPTObserverUserInfo userInfo);
void SPTPositionRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTPositionWillPerishObserver) (SPTObserverUserInfo);
SPTObserverToken SPTPositionAddWillPerishObserver(SPTObject object, SPTPositionWillPerishObserver observer, SPTObserverUserInfo userInfo);
void SPTPositionRemoveWillPerishObserver(SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
