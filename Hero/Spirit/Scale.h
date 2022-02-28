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

void SPTScaleMake(SPTObject object, simd_float3 scale);

void SPTScaleUpdate(SPTObject object, simd_float3 scale);

simd_float3 SPTScaleGet(SPTObject object);

void SPTScaleAddWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTScaleRemoveWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTScaleRemoveWillChangeListener(SPTObject object, SPTComponentListener listener);

SPT_EXTERN_C_END
