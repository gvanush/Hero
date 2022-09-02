//
//  PolylineLook.h
//  Hero
//
//  Created by Vanush Grigoryan on 06.12.21.
//

#pragma once

#include "Base.h"
#include "Polyline.h"

#include <simd/simd.h>


SPT_EXTERN_C_BEGIN

typedef struct {
    simd_float4 color;
    SPTPolylineId polylineId;
    float thickness;
    SPTLookCategories categories;
} SPTPolylineLook;

bool SPTPolylineLookEqual(SPTPolylineLook lhs, SPTPolylineLook rhs);

void SPTPolylineLookMake(SPTObject object, SPTPolylineLook polylineLook);

void SPTPolylineLookUpdate(SPTObject object, SPTPolylineLook polylineLook);

void SPTPolylineLookDestroy(SPTObject object);

SPTPolylineLook SPTPolylineLookGet(SPTObject object);

const SPTPolylineLook* _Nullable SPTPolylineLookTryGet(SPTObject object);

bool SPTPolylineLookExists(SPTObject object);

SPT_EXTERN_C_END
