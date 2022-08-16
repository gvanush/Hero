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

typedef struct {
    simd_float3 xyz;
} SPTScale;

bool SPTScaleEqual(SPTScale lhs, SPTScale rhs);

void SPTScaleMake(SPTObject object, SPTScale scale);

void SPTScaleUpdate(SPTObject object, SPTScale scale);

void SPTScaleDestroy(SPTObject object);

SPTScale SPTScaleGet(SPTObject object);

const SPTScale* _Nullable SPTScaleTryGet(SPTObject object);

bool SPTScaleExists(SPTObject object);

typedef void (* _Nonnull SPTScaleWillChangeObserver) (SPTScale, SPTComponentObserverUserInfo);
SPTObserverToken SPTScaleAddWillChangeObserver(SPTObject object, SPTScaleWillChangeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTScaleRemoveWillChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTScaleWillEmergeObserver) (SPTScale, SPTComponentObserverUserInfo);
SPTObserverToken SPTScaleAddWillEmergeObserver(SPTObject object, SPTScaleWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTScaleRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTScaleWillPerishObserver) (SPTComponentObserverUserInfo);
SPTObserverToken SPTScaleAddWillPerishObserver(SPTObject object, SPTScaleWillPerishObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTScaleRemoveWillPerishObserver(SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
