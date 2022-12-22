//
//  Camera.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#pragma once

#include <simd/simd.h>

#include "Base.hpp"
#include "Camera.h"


namespace spt {

struct ProjectionMatrix {
    simd_float4x4 float4x4;
    bool isDirty;
};

namespace Camera {

simd_float4x4 getViewMatrix(Registry& registry, SPTEntity entity);
simd_float4x4 getProjectionMatrix(Registry& registry, SPTEntity entity);
simd_float4x4 getProjectionViewMatrix(Registry& registry, SPTEntity entity);
simd_float4x4 getProjectionViewMatrix(SPTObject object);

void updatePerspectiveAspectRatio(Registry& registry, SPTEntity entity, float aspectRatio);

}

}
