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

typedef struct {
    simd_float3 float3;
} SPTPosition;

namespace spt {

struct TransformationMatrix {
    simd_float4x4 float4x4;
    bool isDirty;
};

simd_float3 computeSphericalPosition(const SPTSphericalPosition& sphericalPosition) {
    float lngSin = sinf(sphericalPosition.longitude);
    float lngCos = cosf(sphericalPosition.longitude);
    float latSin = sinf(sphericalPosition.latitude);
    float latCos = cosf(sphericalPosition.latitude);
    return sphericalPosition.center + sphericalPosition.radius * simd_make_float3(lngSin * latSin, latCos, lngCos * latSin);
}

void applyLookAtMatrix(simd_float3 pos, const SPTLookAtOrientation& lookAtOrientation, simd_float4x4& matrix) {
    using namespace simd;
    auto zAxis = normalize(lookAtOrientation.target - pos);
    auto xAxis = normalize(cross(lookAtOrientation.up, zAxis));
    matrix.columns[1] = simd_make_float4(normalize(cross(zAxis, xAxis)), matrix.columns[1][3]);
    matrix.columns[0] = simd_make_float4(xAxis, matrix.columns[0][3]);
    matrix.columns[2] = simd_make_float4(zAxis, matrix.columns[2][3]);
}

simd_float4x4 computeTransformationMatrix(spt::Registry& registry, SPTEntity entity) {
    auto matrix = matrix_identity_float4x4;
    
    const auto [position, sphericalPosition] = registry.try_get<SPTPosition, SPTSphericalPosition>(entity);
    if(position) {
        matrix.columns[3].xyz = position->float3;
    } else if(sphericalPosition) {
        matrix.columns[3].xyz = computeSphericalPosition(*sphericalPosition);
    }
    
    const auto lookAtOrientation = registry.try_get<SPTLookAtOrientation>(entity);
    if(lookAtOrientation) {
        applyLookAtMatrix(matrix.columns[3].xyz, *lookAtOrientation, matrix);
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

// MARK: Position
simd_float3 SPTMakePosition(SPTObject object, float x, float y, float z) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    assert(!registry.any_of<SPTSphericalPosition>(object.entity));
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<SPTPosition>(object.entity, simd_float3 {x, y, z}).float3;
}

simd_float3 SPTMakePositionZero(SPTObject object) {
    return SPTMakePosition(object, 0.f, 0.f, 0.f);
}

simd_float3 SPTUpdatePosition(SPTObject object, float x, float y, float z) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& matrix) { matrix.isDirty = true; });
    return registry.replace<SPTPosition>(object.entity, simd_float3 {x, y, z}).float3;
}

simd_float3 SPTGetPosition(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<SPTPosition>(object.entity).float3;
}

// MARK: SphericalPosition
SPTSphericalPosition SPTMakeSphericalPosition(SPTObject object, simd_float3 center, float radius, float longitude, float latitude) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    assert(!registry.any_of<SPTPosition>(object.entity));
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<SPTSphericalPosition>(object.entity, center, radius, longitude, latitude);
}

void SPTUpdateSphericalPosition(SPTObject object, SPTSphericalPosition pos) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& tranMat) { tranMat.isDirty = true; });
    registry.replace<SPTSphericalPosition>(object.entity, pos);
}

SPTSphericalPosition SPTGetSphericalPosition(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<SPTSphericalPosition>(object.entity);
}

// MARK: LookAtOrientation
SPTLookAtOrientation SPTMakeLookAtOrientation(SPTObject object, simd_float3 target, simd_float3 up) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    assert(!registry.any_of<SPTLookAtOrientation>(object.entity));
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<SPTLookAtOrientation>(object.entity, target, up);
}

void SPTUpdateLookAtOrientation(SPTObject object, SPTLookAtOrientation orientation) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& tranMat) { tranMat.isDirty = true; });
    registry.replace<SPTLookAtOrientation>(object.entity, orientation);
}

SPTLookAtOrientation SPTGetLookAtOrientation(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<SPTLookAtOrientation>(object.entity);
}
