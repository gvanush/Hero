//
//  Materials.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 01.09.22.
//

#include "Materials.h"


bool SPTPlainColorMaterialEqual(SPTPlainColorMaterial lhs, SPTPlainColorMaterial rhs) {
    return simd_equal(lhs.color, rhs.color);
}

bool SPTPhongMaterialEqual(SPTPhongMaterial lhs, SPTPhongMaterial rhs) {
    return simd_equal(lhs.color, rhs.color) && lhs.specularRoughness == rhs.specularRoughness;
}