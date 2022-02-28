//
//  Camera.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#pragma once

#include <simd/simd.h>

namespace spt {

namespace Camera {

simd_float4x4 getViewMatrix(SPTObject object);
simd_float4x4 getProjectionMatrix(SPTObject object);
simd_float4x4 getProjectionViewMatrix(SPTObject object);

}

}
