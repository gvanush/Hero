//
//  CoordinateSystem.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 21.11.22.
//

#include "CoordinateSystem.h"

#include <cmath>

bool SPTLinearCoordinatesEqual(SPTLinearCoordinates lhs, SPTLinearCoordinates rhs) {
    return simd_equal(lhs.origin, rhs.origin) && simd_equal(lhs.direction, rhs.direction) && lhs.offset == rhs.offset;
}

SPTLinearCoordinates SPTLinearCoordinatesCreate(simd_float3 origin, simd_float3 cartesian) {
    const auto& direction = cartesian - origin;
    return {origin, direction, simd_length(direction)};
}

bool SPTSphericalCoordinatesEqual(SPTSphericalCoordinates lhs, SPTSphericalCoordinates rhs) {
    return simd_equal(lhs.origin, rhs.origin) &&
    lhs.radius == rhs.radius &&
    lhs.longitude == rhs.longitude &&
    lhs.latitude == rhs.latitude;
}

SPTSphericalCoordinates SPTSphericalCoordinatesCreate(simd_float3 origin, simd_float3 cartesian) {
    const auto& point = cartesian - origin;
    
    const auto t = point.x * point.x + point.z * point.z;
    const auto r = sqrtf(t + point.y * point.y);
    const auto k = point.y / r;
    if(k < -1.f || k > 1.f || isnan(k)) {
        return {origin, 0.f, 0.f, 0.f};
    }
    const auto m = point.z / sqrtf(t);
    if(m < -1.f || m > 1.f || isnan(m)) {
        return {origin, r, 0.f, acosf(k)};
    }
    return {origin, r, copysignf(1, point.x) * acosf(m), acosf(k)};
}

bool SPTCylindricalCoordinatesEqual(SPTCylindricalCoordinates lhs, SPTCylindricalCoordinates rhs) {
    return simd_equal(lhs.origin, rhs.origin) &&
    lhs.radius == rhs.radius &&
    lhs.longitude == rhs.longitude &&
    lhs.height == rhs.height;;
}

SPTCylindricalCoordinates SPTCylindricalCoordinatesCreate(simd_float3 origin, simd_float3 cartesian) {
    const auto& point = cartesian - origin;
    const auto radius = sqrtf(point.z * point.z + point.x * point.x);
    const auto k = point.x / radius;
    if(k < -1.f || k > 1.f || isnan(k)) {
        return {origin, 0.f, 0.f, point.y};
    }
    return {origin, radius, (point.z >= 0.f ? asinf(k) : static_cast<float>(M_PI) - asinf(k)), point.y};
}

// MARK: Conversions
simd_float3 SPTLinearCoordinatesToCartesian(SPTLinearCoordinates linear) {
    return linear.origin + linear.offset * simd_normalize(linear.direction);
}

simd_float3 SPTSphericalCoordinatesToCartesian(SPTSphericalCoordinates spherical) {
    const auto lngSin = sinf(spherical.longitude);
    const auto lngCos = cosf(spherical.longitude);
    const auto latSin = sinf(spherical.latitude);
    const auto latCos = cosf(spherical.latitude);
    return spherical.origin + spherical.radius * simd_make_float3(lngSin * latSin, latCos, lngCos * latSin);
}

simd_float3 SPTCylindricalCoordinatesToCartesian(SPTCylindricalCoordinates cylindrical) {
    return cylindrical.origin + simd_float3{ cylindrical.radius * sinf(cylindrical.longitude), cylindrical.height, cylindrical.radius * cosf(cylindrical.longitude) };
}
