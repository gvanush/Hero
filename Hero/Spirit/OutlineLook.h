//
//  OutlineLook.h
//  Hero
//
//  Created by Vanush Grigoryan on 19.12.21.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef struct {
    simd_float4 color;
    float thickness;
    SPTLookCategories categories;
} SPTOutlineLook;

bool SPTOutlineLookEqual(SPTOutlineLook lhs, SPTOutlineLook rhs);

void SPTOutlineLookMake(SPTObject object, SPTOutlineLook outlineLook);

void SPTOutlineLookUpdate(SPTObject object, SPTOutlineLook outlineLook);

void SPTOutlineLookDestroy(SPTObject object);

SPTOutlineLook SPTOutlineLookGet(SPTObject object);

const SPTOutlineLook* _Nullable SPTOutlineLookTryGet(SPTObject object);

bool SPTOutlineLookExists(SPTObject object);

SPT_EXTERN_C_END
