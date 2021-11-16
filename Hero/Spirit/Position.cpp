//
//  Position.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Position.h"

#include "Scene.hpp"

typedef struct {
    simd_float3 float3;
} spt_position;

simd_float3 spt_make_position_zero(spt_entity entity) {
    return static_cast<spt::Scene*>(entity.sceneHandle)->registry.emplace<spt_position>(entity.id, simd_float3 {}).float3;
}

simd_float3 spt_make_position(spt_entity entity, float x, float y, float z) {
    return static_cast<spt::Scene*>(entity.sceneHandle)->registry.emplace<spt_position>(entity.id, simd_float3 {x, y, z}).float3;
}

simd_float3 spt_update_position(spt_entity entity, float x, float y, float z) {
    return static_cast<spt::Scene*>(entity.sceneHandle)->registry.replace<spt_position>(entity.id, simd_float3 {x, y, z}).float3;
}

simd_float3 spt_get_position(spt_entity entity) {
    return static_cast<spt::Scene*>(entity.sceneHandle)->registry.get<spt_position>(entity.id).float3;
}
