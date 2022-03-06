//
//  OutlineView.h
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
} SPTOutlineView;

SPTOutlineView SPTOutlineViewMake(SPTObject object, simd_float4 color, float thickness);

void SPTOutlineViewDestroy(SPTObject object);

SPT_EXTERN_C_END
