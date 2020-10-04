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

}
