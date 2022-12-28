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

typedef enum {
    SPTScaleModelXYZ,
    SPTScaleModelUniform,
} __attribute__((enum_extensibility(closed))) SPTScaleModel;

typedef struct {
    SPTScaleModel model;
    union {
        simd_float3 xyz;
        float uniform;
    };
} SPTScale;

bool SPTScaleEqual(SPTScale lhs, SPTScale rhs);

void SPTScaleMake(SPTObject object, SPTScale scale);

void SPTScaleUpdate(SPTObject object, SPTScale scale);

void SPTScaleDestroy(SPTObject object);

SPTScale SPTScaleGet(SPTObject object);

const SPTScale* _Nullable SPTScaleTryGet(SPTObject object);

bool SPTScaleExists(SPTObject object);

typedef void (* _Nonnull SPTScaleWillChangeObserver) (SPTScale, SPTObserverUserInfo);
SPTObserverToken SPTScaleAddWillChangeObserver(SPTObject object, SPTScaleWillChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTScaleRemoveWillChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTScaleDidChangeObserver) (SPTScale, SPTObserverUserInfo);
SPTObserverToken SPTScaleAddDidChangeObserver(SPTObject object, SPTScaleDidChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTScaleRemoveDidChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTScaleDidEmergeObserver) (SPTScale, SPTObserverUserInfo);
SPTObserverToken SPTScaleAddDidEmergeObserver(SPTObject object, SPTScaleDidEmergeObserver observer, SPTObserverUserInfo userInfo);
void SPTScaleRemoveDidEmergeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTScaleWillPerishObserver) (SPTObserverUserInfo);
SPTObserverToken SPTScaleAddWillPerishObserver(SPTObject object, SPTScaleWillPerishObserver observer, SPTObserverUserInfo userInfo);
void SPTScaleRemoveWillPerishObserver(SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
