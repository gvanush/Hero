//
//  Transformation.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 16.11.21.
//

#pragma once

#include <simd/simd.h>

namespace spt {

simd_float4x4 get_transformation_matrix(spt_entity entity);

}
