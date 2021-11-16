//
//  Transformation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Transformation.h"
#include "Transformation.hpp"
#include "Scene.hpp"
#include "Common.hpp"

namespace spt {

struct transformation_matrix {
    simd_float4x4 matrix;
    bool isDirty;
};

simd_float4x4 computeTransformationMatrix(spt::registry& registry, spt_entity_id entityId) {
    auto matrix = matrix_identity_float4x4;
    const auto [position, sphericalPosition] = registry.try_get<spt_position, spt_spherical_position>(entityId);
    if(position) {
        matrix.columns[0][3] = position->position.x;
        matrix.columns[1][3] = position->position.y;
        matrix.columns[2][3] = position->position.z;
    }
    return matrix;
}

simd_float4x4 get_transformation_matrix(spt_entity entity) {
    auto& registry = static_cast<spt::Scene*>(entity.sceneHandle)->registry;
    if(auto transformationMatrix = registry.try_get<transformation_matrix>(entity.id); transformationMatrix) {
        if(transformationMatrix->isDirty) {
            transformationMatrix->matrix = computeTransformationMatrix(registry, entity.id);
            transformationMatrix->isDirty = false;
        }
        return transformationMatrix->matrix;
    }
    return matrix_identity_float4x4;
}

}

simd_float3 spt_make_position_zero(spt_entity entity) {
    return spt_make_position(entity, 0.f, 0.f, 0.f);
}

simd_float3 spt_make_position(spt_entity entity, float x, float y, float z) {
    auto& registry = static_cast<spt::Scene*>(entity.sceneHandle)->registry;
    registry.emplace_or_replace<spt::transformation_matrix>(entity.id, matrix_identity_float4x4, true);
    return registry.emplace<spt_position>(entity.id, simd_float3 {x, y, z}).position;
}

simd_float3 spt_update_position(spt_entity entity, float x, float y, float z) {
    auto& registry = static_cast<spt::Scene*>(entity.sceneHandle)->registry;
    registry.patch<spt::transformation_matrix>(entity.id, [] (auto& matrix) { matrix.isDirty = true; });
    return registry.replace<spt_position>(entity.id, simd_float3 {x, y, z}).position;
}

simd_float3 spt_get_position(spt_entity entity) {
    return static_cast<spt::Scene*>(entity.sceneHandle)->registry.get<spt_position>(entity.id).position;
}
