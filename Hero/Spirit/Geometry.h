//
//  Geometry.h
//  Hero
//
//  Created by Vanush Grigoryan on 01.12.21.
//

#pragma once

#include <simd/simd.h>

typedef struct {
    simd_float3 min, max;
} SPTAABB;

inline SPTAABB SPTAABBExpandToIncludePoint(SPTAABB aabb, simd_float3 point) {
    aabb.min = simd_min(aabb.min, point);
    aabb.max = simd_max(aabb.max, point);
    return aabb;
}

typedef union {
    struct { simd_float3 points[3]; };
    struct { simd_float3 p0, p1, p2; };
} SPTTriangle;
