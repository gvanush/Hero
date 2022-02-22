//
//  Transformation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Transformation.h"
#include "Transformation.hpp"
#include "Position.h"
#include "Orientation.h"
#include "Scene.hpp"
#include "ComponentListenerUtil.hpp"
#include "Base.hpp"

namespace spt {

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
    
    matrix.columns[3].xyz = getPosition(registry, entity);
    
    if(const auto orientation = registry.try_get<SPTOrientation>(entity)) {
        switch (orientation->variantTag) {
            case SPTOrientationVariantTagEuler: {
                applyEulerOrientationMatrix(orientation->euler, matrix);
                break;
            }
            case SPTOrientationVariantTagLookAt: {
                applyLookAtMatrix(matrix.columns[3].xyz, orientation->lookAt, matrix);
                break;
            }
        }
    }
    
    if(const auto scale = registry.try_get<spt::Scale>(entity)) {
        matrix.columns[0] *= scale->float3.x;
        matrix.columns[1] *= scale->float3.y;
        matrix.columns[2] *= scale->float3.z;
    }
    
    return matrix;
}

simd_float3 getPosition(SPTObject object) {
    return getPosition(static_cast<spt::Scene*>(object.sceneHandle)->registry, object.entity);
}

simd_float3 getPosition(const spt::Registry& registry, SPTEntity entity) {
    
    if(const auto position = registry.try_get<SPTPosition>(entity)) {
        switch (position->variantTag) {
            case SPTPositionVariantTagXYZ: {
                return position->xyz;
            }
            case SPTPositionVariantTagSpherical: {
                return SPTGetPositionFromSphericalPosition(position->spherical);
            }
        }
    }
    return {0.f, 0.f, 0.f};
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

// MARK: Scale
simd_float3 SPTMakeScale(SPTObject object, float x, float y, float z) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    return registry.emplace<spt::Scale>(object.entity, simd_float3 {x, y, z}).float3;
}

void SPTUpdateScale(SPTObject object, simd_float3 scale) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<spt::Scale>::onWillChange(registry, object.entity);
    
    registry.get<spt::TransformationMatrix>(object.entity).isDirty = true;
    registry.get<spt::Scale>(object.entity).float3 = scale;
}

simd_float3 SPTGetScale(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<spt::Scale>(object.entity).float3;
}

void SPTAddScaleWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentWillChangeListener<spt::Scale>(object, listener, callback);
}

void SPTRemoveScaleWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentWillChangeListenerCallback<spt::Scale>(object, listener, callback);
}

void SPTRemoveScaleWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<spt::Scale>(object, listener);
}
