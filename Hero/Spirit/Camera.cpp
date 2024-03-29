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
#include "Base.hpp"

namespace spt {

simd_float4x4 computeProjectionMatrix(const SPTPerspectiveCamera& camera) {
    const auto c = 1.f / tanf(0.5f * camera.fovy);
    const auto q = camera.far / (camera.near - camera.far);
    return simd_float4x4 {
        simd_float4 {c / camera.aspectRatio, 0.f, 0.f, 0.f},
        simd_float4 {0.f, c, 0.f, 0.f},
        simd_float4 {0.f, 0.f, q, -1.f},
        simd_float4 {0.f, 0.f, camera.near * q, 0.f}
    };
}

simd_float4x4 computeProjectionMatrix(const SPTOrthographicCamera& camera) {
    const auto sizeX = camera.sizeY * camera.aspectRatio;
    return simd_float4x4 {
        simd_float4 {2.f / sizeX, 0.f, 0.f, 0.f},
        simd_float4 {0.f, 2.f / camera.sizeY, 0.f, 0.f},
        simd_float4 {0.f, 0.f, 1.f / (camera.near - camera.far), 0.f},
        simd_float4 {0.f, 0.f, camera.near / (camera.near - camera.far), 1.f}
    };
}

simd_float4x4 computeViewportMatrix(simd_float2 screenSize) {
    return simd_float4x4 {
        simd_float4 {0.5f * screenSize.x, 0.f, 0.f, 0.f},
        simd_float4 {0.f, -0.5f * screenSize.y, 0.f, 0.f},
        simd_float4 {0.f, 0.f, 1.f, 0.f},
        simd_float4 {0.5f * screenSize.x, 0.5f * screenSize.y, 0.f, 1.f}
    };
}

namespace Camera {

simd_float4x4 getViewMatrix(Registry& registry, SPTEntity entity) {
    return simd_inverse(spt::Transformation::getGlobal(registry, entity));
}

simd_float4x4 getProjectionMatrix(Registry& registry, SPTEntity entity) {
    if(auto projectionMatrix = registry.try_get<ProjectionMatrix>(entity); projectionMatrix) {
        if(projectionMatrix->isDirty) {
            if(const auto perspectiveCamera = registry.try_get<SPTPerspectiveCamera>(entity)) {
                projectionMatrix->float4x4 = spt::computeProjectionMatrix(*perspectiveCamera);
            } else if(const auto orthoCamera = registry.try_get<SPTOrthographicCamera>(entity)) {
                projectionMatrix->float4x4 = spt::computeProjectionMatrix(*orthoCamera);
            } else {
                assert(false);
            }
            projectionMatrix->isDirty = false;
        }
        return projectionMatrix->float4x4;
    }
    return matrix_identity_float4x4;
}

simd_float4x4 getProjectionViewMatrix(Registry& registry, SPTEntity entity) {
    return simd_mul(getProjectionMatrix(registry, entity), getViewMatrix(registry, entity));
}

simd_float4x4 getProjectionViewMatrix(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return getProjectionViewMatrix(registry, object.entity);
}

void updatePerspectiveAspectRatio(Registry& registry, SPTEntity entity, float aspectRatio) {
    registry.get<spt::ProjectionMatrix>(entity).isDirty = true;
    registry.get<SPTPerspectiveCamera>(entity).aspectRatio = aspectRatio;
}

}

}

SPTPerspectiveCamera SPTCameraMakePerspective(SPTObject object, float fovy, float aspectRatio, float near, float far) {
    auto& registry = spt::Scene::getRegistry(object);
    const auto& camera = registry.emplace<SPTPerspectiveCamera>(object.entity, fovy, aspectRatio, near, far);
    registry.emplace<spt::ProjectionMatrix>(object.entity, spt::computeProjectionMatrix(camera), false);
    return camera;
}

SPTOrthographicCamera SPTCameraMakeOrthographic(SPTObject object, float sizeY, float aspectRatio, float near, float far) {
    auto& registry = spt::Scene::getRegistry(object);
    const auto& camera = registry.emplace<SPTOrthographicCamera>(object.entity, sizeY, aspectRatio, near, far);
    registry.emplace<spt::ProjectionMatrix>(object.entity, spt::computeProjectionMatrix(camera), false);
    return camera;
}

void SPTCameraUpdatePerspectiveAspectRatio(SPTObject object, float aspectRatio) {
    spt::Camera::updatePerspectiveAspectRatio(spt::Scene::getRegistry(object), object.entity, aspectRatio);
}

void SPTCameraUpdateOrthographicAspectRatio(SPTObject object, float aspectRatio) {
    auto& registry = spt::Scene::getRegistry(object);
    registry.get<spt::ProjectionMatrix>(object.entity).isDirty = true;
    registry.get<SPTOrthographicCamera>(object.entity).aspectRatio = aspectRatio;
}

simd_float3 SPTCameraConvertWorldToViewport(SPTObject cameraObject, simd_float3 point, simd_float2 viewportSize) {
    auto pos = simd_mul(spt::Camera::getProjectionViewMatrix(cameraObject), simd_make_float4(point, 1.f));
    pos = simd_mul(spt::computeViewportMatrix(viewportSize), pos / pos.w);
    return pos.xyz;
}

simd_float3 SPTCameraConvertViewportToWorld(SPTObject cameraObject, simd_float3 point, simd_float2 viewportSize) {
    auto matrix = simd_mul(simd_inverse(spt::Camera::getProjectionViewMatrix(cameraObject)), simd_inverse(spt::computeViewportMatrix(viewportSize)));
    auto pos = simd_mul(matrix, simd_make_float4(point, 1.f));
    return pos.xyz / pos.w;
}
