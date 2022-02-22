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

void SPTMakeScale(SPTObject object, simd_float3 scale);

void SPTUpdateScale(SPTObject object, simd_float3 scale);

simd_float3 SPTGetScale(SPTObject object);

void SPTAddScaleWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveScaleWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback);
void SPTRemoveScaleWillChangeListener(SPTObject object, SPTComponentListener listener);

SPT_EXTERN_C_END
