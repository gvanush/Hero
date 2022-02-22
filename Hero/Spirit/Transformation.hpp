//
//  Transformation.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 16.11.21.
//

#pragma once

#include "Base.hpp"
#include "Base.h"
#include "Position.h"

#include <simd/simd.h>

namespace spt {

struct TransformationMatrix {
    simd_float4x4 float4x4;
    bool isDirty;
};


const simd_float4x4* getTransformationMatrix(SPTObject object);
const simd_float4x4* getTransformationMatrix(spt::Registry& registry, SPTEntity entity);

}
