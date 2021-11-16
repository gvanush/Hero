//
//  Camera.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#pragma once

#include <simd/simd.h>

namespace spt {

const simd_float4x4* GetProjectionMatrix(SPTObject entity);

}
