//
//  RenderableMaterials.h
//  Hero
//
//  Created by Vanush Grigoryan on 30.10.22.
//

#pragma once

#include <simd/simd.h>

namespace spt {

struct PlainColorRenderableMaterial {
    simd_float4 color;
};


struct PhongRenderableMaterial {
    simd_float4 color;
    float specularRoughness;
};

}
