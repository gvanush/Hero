//
//  ArcLook.h
//  Hero
//
//  Created by Vanush Grigoryan on 06.12.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>


SPT_EXTERN_C_BEGIN

typedef struct {
    simd_float4 color;
    float radius;
    float startAngle;
    float endAngle;
    float thickness;
    SPTLookCategories categories;
} SPTArcLook;

bool SPTArcLookEqual(SPTArcLook lhs, SPTArcLook rhs);

void SPTArcLookMake(SPTObject object, SPTArcLook polylineLook);

void SPTArcLookUpdate(SPTObject object, SPTArcLook polylineLook);

void SPTArcLookDestroy(SPTObject object);

SPTArcLook SPTArcLookGet(SPTObject object);

const SPTArcLook* _Nullable SPTArcLookTryGet(SPTObject object);

bool SPTArcLookExists(SPTObject object);

SPT_EXTERN_C_END
