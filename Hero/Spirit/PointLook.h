//
//  PointLook.h
//  Hero
//
//  Created by Vanush Grigoryan on 04.03.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef struct {
    simd_float4 color;
    float size;
    SPTLookCategories categories;
} SPTPointLook;

bool SPTPointLookEqual(SPTPointLook lhs, SPTPointLook rhs);

void SPTPointLookMake(SPTObject object, SPTPointLook point);

void SPTPointLookUpdate(SPTObject object, SPTPointLook point);

void SPTPointLookDestroy(SPTObject object);

SPTPointLook SPTPointLookGet(SPTObject object);

const SPTPointLook* _Nullable SPTPointLookTryGet(SPTObject object);

bool SPTPointLookExists(SPTObject object);

SPT_EXTERN_C_END
