//
//  Materials.h
//  Hero
//
//  Created by Vanush Grigoryan on 07.01.22.
//

#pragma once

#include <simd/simd.h>

typedef struct {
    simd_float4 color;
} SPTPlainColorMaterial;

bool SPTPlainColorMaterialEqual(SPTPlainColorMaterial lhs, SPTPlainColorMaterial rhs);


typedef struct {
    simd_float4 color;
    float specularRoughness;
} SPTPhongMaterial;

bool SPTPhongMaterialEqual(SPTPhongMaterial lhs, SPTPhongMaterial rhs);
