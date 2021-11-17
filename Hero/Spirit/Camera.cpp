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

simd::float4x4 computePerspectiveMatrix(const SPTPerspectiveCamera& camera) {
    const auto c = 1.f / tanf(0.5f * camera.fovy);
    const auto q = camera.far / (camera.far - camera.near);
    using namespace simd;
    return float4x4 {
        float4 {c / camera.aspectRatio, 0.f, 0.f, 0.f},
        float4 {0.f, c, 0.f, 0.f},
        float4 {0.f, 0.f, q, -camera.near * q},
        float4 {0.f, 0.f, 1.f, 0.f}
    };
}

/*simd::float4x4 spt_make_orthographic_matrix(float l, float r, float b, float t, float n, float f) {
    using namespace simd;
    return float4x4 {
        float4 {2.f / (r - l), 0.f, 0.f, (l + r) / (l - r)},
        float4 {0.f, 2.f / (t - b), 0.f, (b + t) / (b - t)},
        float4 {0.f, 0.f, 1.f / (f - n), n / (n - f)},
        float4 {0.f, 0.f, 0.f, 1.f}
    };
}*/

simd_float4x4 computeViewMatrix(SPTObject object) {
    if(auto tranMatrix = getTransformationMatrix(object); tranMatrix) {
        return simd_inverse(*tranMatrix);
    }
    return matrix_identity_float4x4;
}

simd_float4x4 computeProjectionViewMatrix(SPTObject object) {
    return simd_mul(computeViewMatrix(object), *getProjectionMatrix(object));
}

simd::float4x4 computeViewportMatrix(simd_float2 screenSize) {
    return simd_matrix(simd_float4 {0.5f * screenSize.x, 0.f, 0.f, 0.5f * screenSize.x},
                       simd_float4 {0.f, -0.5f * screenSize.y, 0.f, 0.5f * screenSize.y},
                       simd_float4 {0.f, 0.f, 1.f, 0.f},
                       simd_float4 {0.f, 0.f, 0.f, 1.f});
}

const simd_float4x4* getProjectionMatrix(SPTObject object) {
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
    auto pos = simd_mul(simd_make_float4(point, 1.f), spt::computeProjectionViewMatrix(cmaeraObject));
    pos /= pos.w;
    pos = pos * spt::computeViewportMatrix(viewportSize);
    return simd_make_float3(pos);
}

simd_float3 SPTCameraConvertViewportToWorld(SPTObject cameraObject, simd_float3 point, simd_float2 viewportSize) {
    auto matrix = simd_mul(simd_inverse(spt::computeViewportMatrix(viewportSize)), simd_inverse(spt::computeProjectionViewMatrix(cameraObject)));
    auto pos = simd_mul(simd_make_float4(point, 1.f), matrix);
    return simd_make_float3(pos) / pos.w;
}
