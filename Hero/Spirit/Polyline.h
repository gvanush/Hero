//
//  Polyline.h
//  Hero
//
//  Created by Vanush Grigoryan on 05.12.21.
//

#pragma once

#include <stdint.h>
#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef uint32_t SPTPolylineId;

typedef struct {
    const simd_float3* points;
    uint32_t size;
} SPTPolylineItem;

SPT_EXTERN_C_END
