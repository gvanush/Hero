//
//  Transformation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Transformation.h"
#include "Transformation.hpp"
#include "Scene.hpp"
#include "Base.hpp"

namespace spt {

struct TransformationMatrix {
    simd_float4x4 float4x4;
    bool isDirty;
};

simd_float4x4 computeTransformationMatrix(spt::Registry& registry, SPTEntity entity) {
    auto matrix = matrix_identity_float4x4;
    const auto [position, sphericalPosition] = registry.try_get<SPTPosition, SPTSphericalPosition>(entity);
    if(position) {
        matrix.columns[0][3] = position->float3.x;
        matrix.columns[1][3] = position->float3.y;
        matrix.columns[2][3] = position->float3.z;
    }
    return matrix;
}

const simd_float4x4* getTransformationMatrix(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    if(auto transformationMatrix = registry.try_get<TransformationMatrix>(object.entity); transformationMatrix) {
        if(transformationMatrix->isDirty) {
            transformationMatrix->float4x4 = computeTransformationMatrix(registry, object.entity);
            transformationMatrix->isDirty = false;
        }
        return &transformationMatrix->float4x4;
    }
    return nullptr;
}

}

simd_float3 SPTMakePositionZero(SPTObject object) {
    return SPTMakePosition(object, 0.f, 0.f, 0.f);
}

simd_float3 SPTMakePosition(SPTObject object, float x, float y, float z) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<SPTPosition>(object.entity, simd_float3 {x, y, z}).float3;
}

simd_float3 SPTUpdatePosition(SPTObject object, float x, float y, float z) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& matrix) { matrix.isDirty = true; });
    return registry.replace<SPTPosition>(object.entity, simd_float3 {x, y, z}).float3;
}

simd_float3 SPTGetPosition(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<SPTPosition>(object.entity).float3;
}
