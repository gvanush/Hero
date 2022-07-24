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

SPTScale SPTScaleGet(SPTObject object);

typedef void (* _Nonnull SPTScaleWillChangeCallback) (SPTListener, SPTScale);
void SPTScaleAddWillChangeListener(SPTObject object, SPTListener listener, SPTScaleWillChangeCallback callback);
void SPTScaleRemoveWillChangeListenerCallback(SPTObject object, SPTListener listener, SPTScaleWillChangeCallback callback);
void SPTScaleRemoveWillChangeListener(SPTObject object, SPTListener listener);

SPT_EXTERN_C_END
