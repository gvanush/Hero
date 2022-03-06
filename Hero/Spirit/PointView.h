//
//  PointView.h
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
} SPTPointView;


void SPTPointViewMake(SPTObject object, SPTPointView point);

void SPTPointViewDestroy(SPTObject object);

SPT_EXTERN_C_END
