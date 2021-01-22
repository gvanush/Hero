//
//  GeometryUtils.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 11/30/20.
//

#pragma once

#include <simd/simd.h>
#include <cassert>

#include "GeometryUtils_Common.h"
#include "Numeric.hpp"

namespace hero {

// For all 'contains' functions, first argument is the containee
// and the second argument is the container
inline bool contains(const simd::float2& point, const AABR& aabr) {
    return point.x >= aabr.bottomLeft.x && point.x <= aabr.topRight.x && point.y >= aabr.bottomLeft.y && point.y <= aabr.topRight.y;
}

inline bool intersect(const Ray& ray, const Plane& plane, float tolerance) {
    if  (auto dot = simd::dot(ray.direction, plane.normal); !isNearlyZero(dot, tolerance)) {
        return simd::dot(plane.point - ray.origin, plane.normal) / dot >= 0.f;
    }
    return false;
}

inline bool intersect(const Ray& ray, const Plane& plane, float tolerance, float& normalizedDistance) {
    if  (auto dot = simd::dot(ray.direction, plane.normal); !isNearlyZero(dot, tolerance)) {
        return (normalizedDistance = simd::dot(plane.point - ray.origin, plane.normal) / dot) >= 0.f;
    }
    return false;
}

inline Ray transform(const Ray& ray, const simd::float4x4& matrix) {
    Ray result;
    result.origin = ray.origin * matrix;
    result.direction = ray.direction * matrix;
    return result;
}

}
