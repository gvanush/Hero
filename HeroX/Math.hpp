//
//  Math.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/28/20.
//

#pragma once

#include "GeometryUtils_Common.h"

#include <cmath>
#include <simd/simd.h>
#include <cassert>

namespace hero {

constexpr simd::float3 kLeft {-1.f, 0.f, 0.f};
constexpr simd::float3 kRight {1.f, 0.f, 0.f};
constexpr simd::float3 kDown {0.f, -1.f, 0.f};
constexpr simd::float3 kUp {0.f, 1.f, 0.f};
constexpr simd::float3 kBackward {0.f, 0.f, -1.f};
constexpr simd::float3 kForward {0.f, 0.f, 1.f};

simd::float4x4 makeTranslationMatrix(float tx, float ty, float tz);
simd::float4x4 makeTranslationMatrix(const simd::float3& t);

simd::float4x4 makeScaleMatrix(float sx, float sy, float sz);
simd::float4x4 makeScaleMatrix(const simd::float3& s);

simd::float4x4 makeRotationXMatrix(float rx);

simd::float4x4 makeRotationYMatrix(float ry);

simd::float4x4 makeRotationZMatrix(float rz);
simd::float3x3 makeRotationZMatrix3x3(float rz);

simd::float4x4 makeOrthographicMatrix(float l, float r, float b, float t, float n, float f);

simd::float4x4 makePerspectiveMatrix(float fovy, float aspectRatio, float n, float f);

// transofrms ndc to viewport coordinates
simd::float4x4 makeViewportMatrix(const simd::float2& viewportSize);

simd::float3x3 makeLookAtMatrix(const simd::float3& pos, const simd::float3& target, const simd::float3& up);

simd::float3 getRotationMatrixEulerAngles(const simd::float3x3& rotMat, EulerOrder eulerOrder);

inline constexpr float deg2Rad(float deg) {
    return deg * M_PI / 180.f;
}

inline constexpr float rad2Deg(float rad) {
    return rad * 180.f / M_PI;
}

inline simd::float2 getDeviatedUnitVector(const simd::float2& source, float deviationAngle) {
    auto angle = atan2f(source.y, source.x) + deviationAngle;
    return simd::float2 {cosf(angle), sinf(angle)};
}

inline std::size_t maxIndex(const simd::float3& vec) {
    return (vec.x < vec.y ? (vec.y < vec.z ? 2 : 1) : (vec.x < vec.z ? 2 : 0));
}

inline std::size_t minIndex(const simd::float3& vec) {
    return (vec.x < vec.y ? (vec.x < vec.z ? 0 : 2) : (vec.y < vec.z ? 1 : 2));
}

inline simd::float3 getNormalVector(const simd::float3& vec) {
    switch (minIndex(simd::abs(vec))) {
        case 0: {
            return simd::float3 { 0.f, -vec.z, vec.y };
        }
        case 1: {
            return simd::float3 { -vec.z, 0.f, vec.x };
        }
        case 2: {
            return simd::float3 { -vec.y, vec.x, 0.f };
        }
        default: {
            assert(false);
            return simd::float3 {};
        }
    }
}

inline simd::float3 getDeviatedVector(const simd::float3& vec, float deviationAngle) {
    return vec + simd::length(vec) * tanf(deviationAngle) * simd::normalize(getNormalVector(vec));
}

}
