//
//  SIMDUtil.h
//  Hero
//
//  Created by Vanush Grigoryan on 27.10.21.
//

#pragma once

#include <math.h>
#include <simd/simd.h>

const simd_float3 float3_zero = {};
const simd_float3 float3_infinity = {INFINITY, INFINITY, INFINITY};
const simd_float3 float3_negative_infinity = {-INFINITY, -INFINITY, -INFINITY};

inline static simd_float3 SPTToDegFloat3(simd_float3 rad) {
    return rad * 180.f / M_PI;
}

inline static simd_float3 SPTToRadFloat3(simd_float3 deg) {
    return deg * M_PI / 180.f;
}

inline static int SPTMaxComponentIndex(simd_float3 vec) {
    if(vec.x < vec.y) {
        return (vec.y < vec.z ? 2 : 1);
    } else {
        return (vec.x < vec.z ? 2 : 0);
    }
}

inline static int SPTMinComponentIndex(simd_float3 vec) {
    if(vec.x < vec.y) {
        return (vec.x < vec.z ? 0 : 2);
    } else {
        return (vec.y < vec.z ? 1 : 2);
    }
}

inline static bool SPTCollinear(simd_float3 vec1, simd_float3 vec2, float tolerance) {
    return simd_length(simd_cross(vec1, vec2)) < tolerance;
}
