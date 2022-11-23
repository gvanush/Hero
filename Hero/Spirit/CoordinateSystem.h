//
//  CoordinateSystem.h
//  Hero
//
//  Created by Vanush Grigoryan on 21.11.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTCoordinateSystemCartesian,
    SPTCoordinateSystemLinear,
    SPTCoordinateSystemSpherical,
    SPTCoordinateSystemCylindrical
} __attribute__((enum_extensibility(closed))) SPTCoordinateSystem;

// MARK: Linear
typedef struct {
    simd_float3 origin;
    simd_float3 target;
    float factor;
} SPTLinearCoordinates;

bool SPTLinearCoordinatesEqual(SPTLinearCoordinates lhs, SPTLinearCoordinates rhs);

SPTLinearCoordinates SPTLinearCoordinatesCreate(simd_float3 origin, simd_float3 cartesian);

// MARK: Spherical
typedef struct {
    simd_float3 origin;
    float radius;
    float longitude; // relative to z
    float latitude; // relative to y
} SPTSphericalCoordinates;

bool SPTSphericalCoordinatesEqual(SPTSphericalCoordinates lhs, SPTSphericalCoordinates rhs);

SPTSphericalCoordinates SPTSphericalCoordinatesCreate(simd_float3 origin, simd_float3 cartesian);

// MARK: Cylindrical
typedef struct {
    simd_float3 origin;
    float radius;
    float longitude; // relative to z
    float height;
} SPTCylindricalCoordinates;

bool SPTCylindricalCoordinatesEqual(SPTCylindricalCoordinates lhs, SPTCylindricalCoordinates rhs);

SPTCylindricalCoordinates SPTCylindricalCoordinatesCreate(simd_float3 origin, simd_float3 cartesian);

// MARK: Conversions
simd_float3 SPTLinearCoordinatesToCartesian(SPTLinearCoordinates linear);

simd_float3 SPTSphericalCoordinatesToCartesian(SPTSphericalCoordinates spherical);

simd_float3 SPTCylindricalCoordinatesToCartesian(SPTCylindricalCoordinates cylindrical);

SPT_EXTERN_C_END
