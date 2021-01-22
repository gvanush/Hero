//
//  GeometryUtils_Common.h
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

#include <simd/simd.h>

#ifdef __cplusplus
extern "C" {
#endif

const simd_float3 kZero = {0.f, 0.f, 0.f};
const simd_float3 kOne = {1.f, 1.f, 1.f};
const simd_float3 kLeft = {-1.f, 0.f, 0.f};
const simd_float3 kRight = {1.f, 0.f, 0.f};
const simd_float3 kDown = {0.f, -1.f, 0.f};
const simd_float3 kUp = {0.f, 1.f, 0.f};
const simd_float3 kBackward = {0.f, 0.f, -1.f};
const simd_float3 kForward = {0.f, 0.f, 1.f};

typedef enum {
    EulerOrder_xyz,
    EulerOrder_xzy,
    EulerOrder_yxz,
    EulerOrder_yzx,
    EulerOrder_zxy,
    EulerOrder_zyx
} RotationMode;

typedef enum {
    Projection_ortographic,
    Projection_perspective
} Projection;

// MARK: Axis-aligned bounding rectangle
typedef struct {
    simd_float2 bottomLeft;
    simd_float2 topRight;
} AABR;

// MARK: Ray
typedef struct {
    simd_float4 origin;
    simd_float4 direction;
} Ray;

static inline Ray makeRay(simd_float3 origin, simd_float3 direction) {
    Ray ray;
    ray.origin = simd_make_float4(origin, 1.f);
    ray.direction = simd_make_float4(direction);
    return ray;
}

static inline simd_float4 getRayPoint(Ray ray, float normalizedDistance) {
    return ray.origin + normalizedDistance * ray.direction;
}

// MARK: Plane
typedef struct {
    simd_float4 point;
    simd_float4 normal;
} Plane;

static inline Plane makePlane(simd_float3 point, simd_float3 normal) {
    Plane plane;
    plane.point = simd_make_float4(point, 1.f);
    plane.normal = simd_make_float4(normal);
    return plane;
}

#ifdef __cplusplus
}
#endif
