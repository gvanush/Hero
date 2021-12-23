//
//  Transformation.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 16.11.21.
//

#pragma once

#include "Base.hpp"
#include "Base.h"

#include <simd/simd.h>

namespace spt {

struct Position {
    simd_float3 float3;
};

struct Scale {
    simd_float3 float3;
};

const simd_float4x4* getTransformationMatrix(SPTObject object);
const simd_float4x4* getTransformationMatrix(spt::Registry& registry, SPTEntity entity);

}
