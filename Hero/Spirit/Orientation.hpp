//
//  Orientation.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 13.09.22.
//

#pragma once

#include "Base.hpp"
#include "Orientation.h"


namespace spt::Orientation {

simd_float3x3 computeEulerOrientationMatrix(const SPTEulerOrientation& eulerOrientation);

simd_float3x3 computeLookAtMatrix(simd_float3 pos, const SPTLookAtPointOrientation& lookAtOrientation);

simd_float4x4 getMatrix(const spt::Registry& registry, SPTEntity entity, const simd_float3& position);

}
