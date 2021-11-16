//
//  Position.h
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "Common.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

simd_float3 spt_make_position_zero(spt_entity entity);
simd_float3 spt_make_position(spt_entity entity, float x, float y, float z);

simd_float3 spt_update_position(spt_entity entity, float x, float y, float z);

simd_float3 spt_get_position(spt_entity entity);

SPT_EXTERN_C_END
