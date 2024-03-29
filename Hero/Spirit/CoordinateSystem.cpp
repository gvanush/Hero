//
//  CoordinateSystem.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 21.11.22.
//

#include "CoordinateSystem.h"

#include <cmath>

// MARK: Linear
bool SPTLinearCoordinatesEqual(SPTLinearCoordinates lhs, SPTLinearCoordinates rhs) {
    return simd_equal(lhs.origin, rhs.origin) && simd_equal(lhs.direction, rhs.direction) && lhs.offset == rhs.offset;
}

SPTLinearCoordinates SPTLinearCoordinatesCreate(simd_float3 origin, simd_float3 cartesian) {
    const auto& direction = cartesian - origin;
    return {origin, direction, simd_length(direction)};
}

SPTLinearCoordinates SPTLinearCoordinatesAdd(SPTLinearCoordinates lhs, SPTLinearCoordinates rhs) {
    return {lhs.origin + rhs.origin, lhs.direction + rhs.direction, lhs.offset + rhs.offset};
}

SPTLinearCoordinates SPTLinearCoordinatesSubtract(SPTLinearCoordinates lhs, SPTLinearCoordinates rhs) {
    return {lhs.origin - rhs.origin, lhs.direction - rhs.direction, lhs.offset - rhs.offset};
}

SPTLinearCoordinates SPTLinearCoordinatesMultiplyScalar(SPTLinearCoordinates coord, float scalar) {
    return {scalar * coord.origin, scalar * coord.direction, scalar * coord.offset};
}

// MARK: Spherical
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

SPTSphericalCoordinates SPTSphericalCoordinatesAdd(SPTSphericalCoordinates lhs, SPTSphericalCoordinates rhs) {
    return {lhs.origin + rhs.origin, lhs.radius + rhs.radius, lhs.longitude + rhs.longitude, lhs.latitude + rhs.latitude};
}

SPTSphericalCoordinates SPTSphericalCoordinatesSubtract(SPTSphericalCoordinates lhs, SPTSphericalCoordinates rhs) {
    return {lhs.origin - rhs.origin, lhs.radius - rhs.radius, lhs.longitude - rhs.longitude, lhs.latitude - rhs.latitude};
}

SPTSphericalCoordinates SPTSphericalCoordinatesMultiplyScalar(SPTSphericalCoordinates coord, float scalar) {
    return {scalar * coord.origin, scalar * coord.radius, scalar * coord.longitude, scalar * coord.latitude};
}

// MARK: Cylindrical
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

SPTCylindricalCoordinates SPTCylindricalCoordinatesAdd(SPTCylindricalCoordinates lhs, SPTCylindricalCoordinates rhs) {
    return {lhs.origin + rhs.origin, lhs.radius + rhs.radius, lhs.longitude + rhs.longitude, lhs.height + rhs.height};
}

SPTCylindricalCoordinates SPTCylindricalCoordinatesSubtract(SPTCylindricalCoordinates lhs, SPTCylindricalCoordinates rhs) {
    return {lhs.origin - rhs.origin, lhs.radius - rhs.radius, lhs.longitude - rhs.longitude, lhs.height - rhs.height};
}

SPTCylindricalCoordinates SPTCylindricalCoordinatesMultiplyScalar(SPTCylindricalCoordinates coord, float scalar) {
    return {scalar * coord.origin, scalar * coord.radius, scalar * coord.longitude, scalar * coord.height};
}

// MARK: Conversions
simd_float3 SPTLinearCoordinatesToCartesian(SPTLinearCoordinates linear) {
    const auto dirLength = simd_length(linear.direction);
    if(dirLength < 0.0001) {
        return linear.origin;
    }
    return linear.origin + linear.offset / dirLength * linear.direction;
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
