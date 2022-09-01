//
//  Materials.h
//  Hero
//
//  Created by Vanush Grigoryan on 07.01.22.
//

#pragma once

#ifndef __METAL_VERSION__

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

#endif

typedef struct {
    simd_float4 color;
} SPTPlainColorMaterial;

bool SPTPlainColorMaterialEqual(SPTPlainColorMaterial lhs, SPTPlainColorMaterial rhs);


typedef struct {
    simd_float4 color;
    float specularRoughness;
} SPTPhongMaterial;

bool SPTPhongMaterialEqual(SPTPhongMaterial lhs, SPTPhongMaterial rhs);

#ifndef __METAL_VERSION__

SPT_EXTERN_C_END

#endif
