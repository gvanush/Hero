//
//  PolylineView.h
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
} SPTPolylineView;

SPTPolylineView SPTPolylineViewMake(SPTObject object, SPTPolylineId polylineId, simd_float4 color, float thickness);

SPT_EXTERN_C_END
