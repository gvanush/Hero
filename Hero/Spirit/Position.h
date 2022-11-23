//
//  Position.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#pragma once

#include "Base.h"
#include "CoordinateSystem.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef struct {
    SPTCoordinateSystem coordinateSystem;
    union {
        simd_float3 cartesian;
        SPTLinearCoordinates linear;
        SPTSphericalCoordinates spherical;
        SPTCylindricalCoordinates cylindrical;
    };
} SPTPosition;

bool SPTPositionEqual(SPTPosition lhs, SPTPosition rhs);

void SPTPositionMake(SPTObject object, SPTPosition position);

void SPTPositionUpdate(SPTObject object, SPTPosition position);

void SPTPositionDestroy(SPTObject object);

SPTPosition SPTPositionGet(SPTObject object);

const SPTPosition* _Nullable SPTPositionTryGet(SPTObject object);

bool SPTPositionExists(SPTObject object);

SPTPosition SPTPositionToCartesian(SPTPosition position);
SPTPosition SPTPositionToLinear(SPTPosition position, simd_float3 origin);
SPTPosition SPTPositionToSpherical(SPTPosition position, simd_float3 origin);
SPTPosition SPTPositionToCylindrical(SPTPosition position, simd_float3 origin);

typedef void (* _Nonnull SPTPositionWillChangeObserver) (SPTPosition, SPTObserverUserInfo);
SPTObserverToken SPTPositionAddWillChangeObserver(SPTObject object, SPTPositionWillChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTPositionRemoveWillChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTPositionDidEmergeObserver) (SPTPosition, SPTObserverUserInfo);
SPTObserverToken SPTPositionAddDidEmergeObserver(SPTObject object, SPTPositionDidEmergeObserver observer, SPTObserverUserInfo userInfo);
void SPTPositionRemoveDidEmergeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTPositionWillPerishObserver) (SPTObserverUserInfo);
SPTObserverToken SPTPositionAddWillPerishObserver(SPTObject object, SPTPositionWillPerishObserver observer, SPTObserverUserInfo userInfo);
void SPTPositionRemoveWillPerishObserver(SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
