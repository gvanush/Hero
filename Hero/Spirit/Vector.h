//
//  Vector.h
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

const simd_float3 SPTVectorLeft = {-1.f, 0.f, 0.f};
const simd_float3 SPTVectorRight = {1.f, 0.f, 0.f};
const simd_float3 SPTVectorUp = {0.f, 1.f, 0.f};
const simd_float3 SPTVectorDown = {0.f, -1.f, 0.f};
const simd_float3 SPTVectorForward = {0.f, 0.f, -1.f};
const simd_float3 SPTVectorBackward = {0.f, 0.f, 1.f};

inline static simd_float3 SPTVectorRadiansToDegrees(simd_float3 rad) {
    return rad * 180.f / M_PI;
}

inline static simd_float3 SPTVectorDegreesToRadians(simd_float3 deg) {
    return deg * M_PI / 180.f;
}

inline static float SPTVectorMaxComponent(simd_float3 vec) {
    if(vec.x < vec.y) {
        return (vec.y < vec.z ? vec.z : vec.y);
    } else {
        return (vec.x < vec.z ? vec.z : vec.x);
    }
}

inline static float SPTVectorMinComponent(simd_float3 vec) {
    if(vec.x < vec.y) {
        return (vec.x < vec.z ? vec.x : vec.z);
    } else {
        return (vec.y < vec.z ? vec.y : vec.z);
    }
}

inline static int SPTVectorMaxComponentIndex(simd_float3 vec) {
    if(vec.x < vec.y) {
        return (vec.y < vec.z ? 2 : 1);
    } else {
        return (vec.x < vec.z ? 2 : 0);
    }
}

inline static int SPTVectorMinComponentIndex(simd_float3 vec) {
    if(vec.x < vec.y) {
        return (vec.x < vec.z ? 0 : 2);
    } else {
        return (vec.y < vec.z ? 1 : 2);
    }
}

inline static simd_float3 SPTVectorCreateOrthogonal(simd_float3 vec) {
    simd_float3 ortho = {0.f, 0.f, 0.f};
    
    if(ortho.x < ortho.y) {
        if(ortho.x < ortho.z) {
            ortho.z = -vec.y;
            ortho.y = vec.z;
        } else {
            ortho.x = -vec.y;
            ortho.y = vec.x;
        }
    } else {
        if(ortho.y < ortho.z) {
            ortho.x = -vec.z;
            ortho.z = vec.x;
        } else {
            ortho.x = -vec.y;
            ortho.y = vec.x;
        }
    }
    
    return ortho;
}

inline static bool SPTVectorCollinear(simd_float3 vec1, simd_float3 vec2, float tolerance) {
    return simd_length(simd_cross(vec1, vec2)) < tolerance;
}

inline static simd_float3 SPTVectorGetPositiveDirection(SPTAxis axis) {
    switch (axis) {
        case SPTAxisX:
            return SPTVectorRight;
        case SPTAxisY:
            return SPTVectorUp;
        case SPTAxisZ:
            return SPTVectorBackward;
    }
}
