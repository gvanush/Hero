//
//  Materials.h
//  Hero
//
//  Created by Vanush Grigoryan on 07.01.22.
//

#pragma once

#include "Base.h"
#include "Color.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef struct {
    SPTColor color;
} SPTPlainColorMaterial;

bool SPTPlainColorMaterialEqual(SPTPlainColorMaterial lhs, SPTPlainColorMaterial rhs);


typedef struct {
    SPTColor color;
    float specularRoughness;
} SPTPhongMaterial;

bool SPTPhongMaterialEqual(SPTPhongMaterial lhs, SPTPhongMaterial rhs);

SPT_EXTERN_C_END
