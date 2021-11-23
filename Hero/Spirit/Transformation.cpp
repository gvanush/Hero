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

typedef struct {
    simd_float3 float3;
} SPTScale;

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

simd_float3x3 computeRotationXMatrix(float rx) {
    const auto c = cosf(rx);
    const auto s = sinf(rx);
    return simd_float3x3 {
        simd_float3 {1.f, 0.f, 0.f},
        simd_float3 {0.f, c, s},
        simd_float3 {0.f, -s, c}
    };
}

simd_float3x3 computeRotationYMatrix(float ry) {
    const auto c = cosf(ry);
    const auto s = sinf(ry);
    return simd_float3x3 {
        simd_float3 {c, 0.f, -s},
        simd_float3 {0.f, 1.f, 0.f},
        simd_float3 {s, 0.f, c}
    };
}

simd_float3x3 computeRotationZMatrix(float rz) {
    const auto c = cosf(rz);
    const auto s = sinf(rz);
    return simd_float3x3 {
        simd_float3 {c, s, 0.f},
        simd_float3 {-s, c, 0.f},
        simd_float3 {0.f, 0.f, 1.f}
    };
}

void applyEulerOrientationMatrix(const SPTEulerOrientation& eulerOrientation, simd_float4x4& matrix) {
    
    auto xMat = computeRotationXMatrix(eulerOrientation.x);
    auto yMat = computeRotationYMatrix(eulerOrientation.y);
    auto zMat = computeRotationZMatrix(eulerOrientation.z);
    
    auto rotMat = matrix_identity_float3x3;
    
    switch (eulerOrientation.order) {
        case SPTEulerOrderXYZ:
            rotMat = simd_mul(zMat, simd_mul(yMat, xMat));
            break;
        case SPTEulerOrderXZY:
            rotMat = simd_mul(yMat, simd_mul(zMat, xMat));
            break;
        case SPTEulerOrderYXZ:
            rotMat = simd_mul(zMat, simd_mul(xMat, yMat));
            break;
        case SPTEulerOrderYZX:
            rotMat = simd_mul(xMat, simd_mul(zMat, yMat));
            break;
        case SPTEulerOrderZXY:
            rotMat = simd_mul(yMat, simd_mul(xMat, zMat));
            break;
        case SPTEulerOrderZYX:
            rotMat = simd_mul(xMat, simd_mul(yMat, zMat));
            break;
    }
    
    matrix.columns[0] = simd_make_float4(rotMat.columns[0], matrix.columns[0][3]);
    matrix.columns[1] = simd_make_float4(rotMat.columns[1], matrix.columns[1][3]);
    matrix.columns[2] = simd_make_float4(rotMat.columns[2], matrix.columns[2][3]);
}

void applyLookAtMatrix(simd_float3 pos, const SPTLookAtOrientation& lookAtOrientation, simd_float4x4& matrix) {
    auto zAxis = simd_normalize(lookAtOrientation.target - pos);
    auto xAxis = simd_normalize(simd_cross(lookAtOrientation.up, zAxis));
    matrix.columns[1] = simd_make_float4(simd_normalize(simd_cross(zAxis, xAxis)), matrix.columns[1][3]);
    matrix.columns[0] = simd_make_float4(xAxis, matrix.columns[0][3]);
    matrix.columns[2] = simd_make_float4(zAxis, matrix.columns[2][3]);
}

simd_float4x4 computeTransformationMatrix(const spt::Registry& registry, SPTEntity entity) {
    auto matrix = matrix_identity_float4x4;
    
    const auto [position, sphericalPosition] = registry.try_get<SPTPosition, SPTSphericalPosition>(entity);
    if(position) {
        matrix.columns[3].xyz = position->float3;
    } else if(sphericalPosition) {
        matrix.columns[3].xyz = computeSphericalPosition(*sphericalPosition);
    }
    
    const auto [eulerOrientation, lookAtOrientation] = registry.try_get<SPTEulerOrientation, SPTLookAtOrientation>(entity);
    if(eulerOrientation) {
        applyEulerOrientationMatrix(*eulerOrientation, matrix);
    } else if(lookAtOrientation) {
        applyLookAtMatrix(matrix.columns[3].xyz, *lookAtOrientation, matrix);
    }
    
    const auto scale = registry.try_get<SPTScale>(entity);
    if(scale) {
        matrix.columns[0] *= scale->float3.x;
        matrix.columns[1] *= scale->float3.y;
        matrix.columns[2] *= scale->float3.z;
    }
    
    return matrix;
}

const simd_float4x4* getTransformationMatrix(SPTObject object) {
    return getTransformationMatrix(static_cast<spt::Scene*>(object.sceneHandle)->registry, object.entity);
}

const simd_float4x4* getTransformationMatrix(spt::Registry& registry, SPTEntity entity) {
    if(auto transformationMatrix = registry.try_get<TransformationMatrix>(entity); transformationMatrix) {
        if(transformationMatrix->isDirty) {
            transformationMatrix->float4x4 = computeTransformationMatrix(registry, entity);
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

void SPTUpdatePosition(SPTObject object, simd_float3 position) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& matrix) { matrix.isDirty = true; });
    registry.replace<SPTPosition>(object.entity, position);
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

// MARK: EulerOrientation
SPTEulerOrientation SPTMakeEulerOrientation(SPTObject object, float x, float y, float z, SPTEulerOrder order) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    assert(!registry.any_of<SPTLookAtOrientation>(object.entity));
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<SPTEulerOrientation>(object.entity, x, y, z, order);
}

void SPTUpdateEulerOrientation(SPTObject object, SPTEulerOrientation orientation) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& tranMat) { tranMat.isDirty = true; });
    registry.replace<SPTEulerOrientation>(object.entity, orientation);
}
    
SPTEulerOrientation SPTGetEulerOrientation(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<SPTEulerOrientation>(object.entity);
}

// MARK: LookAtOrientation
SPTLookAtOrientation SPTMakeLookAtOrientation(SPTObject object, simd_float3 target, simd_float3 up) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    assert(!registry.any_of<SPTEulerOrientation>(object.entity));
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

// MARK: Scale
simd_float3 SPTMakeScale(SPTObject object, float x, float y, float z) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<SPTScale>(object.entity, simd_float3 {x, y, z}).float3;
}

void SPTUpdateScale(SPTObject object, simd_float3 scale) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& matrix) { matrix.isDirty = true; });
    registry.replace<SPTScale>(object.entity, scale);
}

simd_float3 SPTGetScale(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<SPTScale>(object.entity).float3;
}
