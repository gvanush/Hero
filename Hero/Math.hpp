//
//  Math.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/28/20.
//

#pragma once

#include "Geometry.h"

#include <simd/simd.h>

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

simd::float4x4 makeOrthographicMatrix(float l, float r, float b, float t, float n, float f);

simd::float4x4 makePerspectiveMatrix(float fovy, float aspectRatio, float n, float f);

// transofrms ndc to viewport coordinates
simd::float4x4 makeViewportMatrix(const Size2& screenSize);

simd::float3x3 makeLookAtMatrix(const simd::float3& pos, const simd::float3& target, const simd::float3& up);

simd::float3 getRotationMatrixEulerAngles(const simd::float3x3& rotMat, EulerOrder eulerOrder);

}
