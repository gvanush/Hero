//
//  Transformation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Transformation.h"
#include "Transformation.hpp"
#include "Scene.hpp"
#include "ComponentListenerUtil.hpp"
#include "Base.hpp"

namespace spt {

struct TransformationMatrix {
    simd_float4x4 float4x4;
    bool isDirty;
};

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
    
    auto xMat = computeRotationXMatrix(eulerOrientation.rotation.x);
    auto yMat = computeRotationYMatrix(eulerOrientation.rotation.y);
    auto zMat = computeRotationZMatrix(eulerOrientation.rotation.z);
    
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
    const auto sign = (lookAtOrientation.positive ? 1 : -1);
    switch(lookAtOrientation.axis) {
        case SPTAxisX: {
            const auto xAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto yAxis = simd_normalize(simd_cross(lookAtOrientation.up, xAxis));
            matrix.columns[2] = simd_make_float4(simd_normalize(simd_cross(xAxis, yAxis)), matrix.columns[2][3]);
            matrix.columns[0] = simd_make_float4(xAxis, matrix.columns[0][3]);
            matrix.columns[1] = simd_make_float4(yAxis, matrix.columns[1][3]);
            break;
        }
        case SPTAxisY: {
            const auto yAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto zAxis = simd_normalize(simd_cross(lookAtOrientation.up, yAxis));
            matrix.columns[0] = simd_make_float4(simd_normalize(simd_cross(yAxis, zAxis)), matrix.columns[0][3]);
            matrix.columns[2] = simd_make_float4(zAxis, matrix.columns[2][3]);
            matrix.columns[1] = simd_make_float4(yAxis, matrix.columns[1][3]);
            break;
        }
        case SPTAxisZ: {
            const auto zAxis = sign * simd_normalize(lookAtOrientation.target - pos);
            const auto xAxis = simd_normalize(simd_cross(lookAtOrientation.up, zAxis));
            matrix.columns[1] = simd_make_float4(simd_normalize(simd_cross(zAxis, xAxis)), matrix.columns[1][3]);
            matrix.columns[0] = simd_make_float4(xAxis, matrix.columns[0][3]);
            matrix.columns[2] = simd_make_float4(zAxis, matrix.columns[2][3]);
            break;
        }
    }
    
}

simd_float4x4 computeTransformationMatrix(const spt::Registry& registry, SPTEntity entity) {
    auto matrix = matrix_identity_float4x4;
    
    const auto [position, sphericalPosition] = registry.try_get<spt::Position, SPTSphericalPosition>(entity);
    if(position) {
        matrix.columns[3].xyz = position->float3;
    } else if(sphericalPosition) {
        matrix.columns[3].xyz = SPTGetPositionFromSphericalPosition(*sphericalPosition);
    }
    
    const auto [eulerOrientation, lookAtOrientation] = registry.try_get<SPTEulerOrientation, SPTLookAtOrientation>(entity);
    if(eulerOrientation) {
        applyEulerOrientationMatrix(*eulerOrientation, matrix);
    } else if(lookAtOrientation) {
        applyLookAtMatrix(matrix.columns[3].xyz, *lookAtOrientation, matrix);
    }
    
    const auto scale = registry.try_get<spt::Scale>(entity);
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
    return registry.emplace<spt::Position>(object.entity, simd_float3 {x, y, z}).float3;
}

simd_float3 SPTMakePositionZero(SPTObject object) {
    return SPTMakePosition(object, 0.f, 0.f, 0.f);
}

void SPTUpdatePosition(SPTObject object, simd_float3 position) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& matrix) { matrix.isDirty = true; });
    registry.replace<spt::Position>(object.entity, position);
}

simd_float3 SPTGetPosition(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<spt::Position>(object.entity).float3;
}

void SPTAddPositionListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentListener<spt::Position>(object, listener, callback);
}

void SPTRemovePositionListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentListenerCallback<spt::Position>(object, listener, callback);
}

void SPTRemovePositionListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentListener<spt::Position>(object, listener);
}

// MARK: SphericalPosition
SPTSphericalPosition SPTMakeSphericalPosition(SPTObject object, simd_float3 center, float radius, float longitude, float latitude) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    assert(!registry.any_of<spt::Position>(object.entity));
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

simd_float3 SPTGetPositionFromSphericalPosition(SPTSphericalPosition sphericalPosition) {
    float lngSin = sinf(sphericalPosition.longitude);
    float lngCos = cosf(sphericalPosition.longitude);
    float latSin = sinf(sphericalPosition.latitude);
    float latCos = cosf(sphericalPosition.latitude);
    return sphericalPosition.center + sphericalPosition.radius * simd_make_float3(lngSin * latSin, latCos, lngCos * latSin);
}

// MARK: EulerOrientation
SPTEulerOrientation SPTMakeEulerOrientation(SPTObject object, simd_float3 rotation, SPTEulerOrder order) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    assert(!registry.any_of<SPTLookAtOrientation>(object.entity));
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<SPTEulerOrientation>(object.entity, rotation, order);
}

void SPTUpdateEulerOrientation(SPTObject object, SPTEulerOrientation orientation) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& tranMat) { tranMat.isDirty = true; });
    registry.replace<SPTEulerOrientation>(object.entity, orientation);
}
    
void SPTUpdateEulerOrientationRotation(SPTObject object, simd_float3 rotation) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& tranMat) { tranMat.isDirty = true; });
    registry.patch<SPTEulerOrientation>(object.entity, [rotation] (auto& eulerOrientaiton) { eulerOrientaiton.rotation = rotation; });
}

SPTEulerOrientation SPTGetEulerOrientation(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<SPTEulerOrientation>(object.entity);
}

void SPTAddEulerOrientationListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentListener<SPTEulerOrientation>(object, listener, callback);
}

void SPTRemoveEulerOrientationListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentListenerCallback<SPTEulerOrientation>(object, listener, callback);
}

void SPTRemoveEulerOrientationListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentListener<SPTEulerOrientation>(object, listener);
}

// MARK: LookAtOrientation
SPTLookAtOrientation SPTMakeLookAtOrientation(SPTObject object, simd_float3 target, SPTAxis axis, bool positive, simd_float3 up) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    assert(!registry.any_of<SPTEulerOrientation>(object.entity));
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<SPTLookAtOrientation>(object.entity, target, up, axis, positive);
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
    return registry.emplace<spt::Scale>(object.entity, simd_float3 {x, y, z}).float3;
}

void SPTUpdateScale(SPTObject object, simd_float3 scale) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::TransformationMatrix>(object.entity, [] (auto& matrix) { matrix.isDirty = true; });
    registry.replace<spt::Scale>(object.entity, scale);
}

simd_float3 SPTGetScale(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<spt::Scale>(object.entity).float3;
}

void SPTAddScaleListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentListener<spt::Scale>(object, listener, callback);
}

void SPTRemoveScaleListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentListenerCallback<spt::Scale>(object, listener, callback);
}

void SPTRemoveScaleListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentListener<spt::Scale>(object, listener);
}
