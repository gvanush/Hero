//
//  Camera.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#include "Camera.h"
#include "Camera.hpp"
#include "Scene.hpp"
#include "Transformation.hpp"

namespace spt {

struct ProjectionMatrix {
    simd_float4x4 float4x4;
    bool isDirty;
};

simd_float4x4 computePerspectiveMatrix(const SPTPerspectiveCamera& camera) {
    const auto c = 1.f / tanf(0.5f * camera.fovy);
    const auto q = camera.far / (camera.far - camera.near);
    return simd_float4x4 {
        simd_float4 {c / camera.aspectRatio, 0.f, 0.f, 0.f},
        simd_float4 {0.f, c, 0.f, 0.f},
        simd_float4 {0.f, 0.f, q, 1.f},
        simd_float4 {0.f, 0.f, -camera.near * q, 0.f}
    };
}

simd_float4x4 computeViewMatrix(SPTObject object) {
    if(auto tranMatrix = getTransformationMatrix(object); tranMatrix) {
        return simd_inverse(*tranMatrix);
    }
    return matrix_identity_float4x4;
}

simd_float4x4 computeViewportMatrix(simd_float2 screenSize) {
    return simd_float4x4 {
        simd_float4 {0.5f * screenSize.x, 0.f, 0.f, 0.f},
        simd_float4 {0.f, -0.5f * screenSize.y, 0.f, 0.f},
        simd_float4 {0.f, 0.f, 1.f, 0.f},
        simd_float4 {0.5f * screenSize.x, 0.5f * screenSize.y, 0.f, 1.f}
    };
}

simd_float4x4 computeCameraProjectionViewMatrix(SPTObject object) {
    const auto projectionMatrix = getCameraProjectionMatrix(object);
    return simd_mul(projectionMatrix ? *projectionMatrix : matrix_identity_float4x4, computeViewMatrix(object));
}

const simd_float4x4* getCameraProjectionMatrix(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    if(auto projectionMatrix = registry.try_get<ProjectionMatrix>(object.entity); projectionMatrix) {
        if(projectionMatrix->isDirty) {
            projectionMatrix->float4x4 = spt::computePerspectiveMatrix(registry.get<SPTPerspectiveCamera>(object.entity));
            projectionMatrix->isDirty = false;
        }
        return &projectionMatrix->float4x4;
    }
    return nullptr;
}

}

SPTPerspectiveCamera SPTMakePerspectiveCamera(SPTObject object, float fovy, float aspectRatio, float near, float far) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    const auto& camera = registry.emplace<SPTPerspectiveCamera>(object.entity, fovy, aspectRatio, near, far);
    registry.emplace<spt::ProjectionMatrix>(object.entity, spt::computePerspectiveMatrix(camera), false);
    return camera;
}

SPTPerspectiveCamera SPTUpdatePerspectiveCameraAspectRatio(SPTObject entity, float aspectRatio) {
    auto& registry = static_cast<spt::Scene*>(entity.sceneHandle)->registry;
    registry.patch<spt::ProjectionMatrix>(entity.entity, [](auto& projectionMatrix) {
        projectionMatrix.isDirty = true;
    });
    return registry.patch<SPTPerspectiveCamera>(entity.entity, [aspectRatio] (auto& camera) {
        camera.aspectRatio = aspectRatio;
    });
}

simd_float3 SPTCameraConvertWorldToViewport(SPTObject cmaeraObject, simd_float3 point, simd_float2 viewportSize) {
    auto pos = simd_mul(spt::computeCameraProjectionViewMatrix(cmaeraObject), simd_make_float4(point, 1.f));
    pos = simd_mul(spt::computeViewportMatrix(viewportSize), pos / pos.w);
    return pos.xyz;
}

simd_float3 SPTCameraConvertViewportToWorld(SPTObject cameraObject, simd_float3 point, simd_float2 viewportSize) {
    auto matrix = simd_mul(simd_inverse(spt::computeCameraProjectionViewMatrix(cameraObject)), simd_inverse(spt::computeViewportMatrix(viewportSize)));
    auto pos = simd_mul(matrix, simd_make_float4(point, 1.f));
    return pos.xyz / pos.w;
}