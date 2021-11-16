//
//  Camera.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#include "Camera.h"
#include "Camera.hpp"
#include "Scene.hpp"

namespace {

simd::float4x4 spt_make_perspective_matrix(const spt_perspective_camera& camera) {
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

}

namespace spt {

struct projection_matrix {
    simd_float4x4 matrix;
    bool isDirty;
};

simd_float4x4 get_projection_matrix(spt_entity entity) {
    auto& registry = static_cast<spt::Scene*>(entity.sceneHandle)->registry;
    if(auto projectionMatrix = registry.try_get<projection_matrix>(entity.id); projectionMatrix) {
        if(projectionMatrix->isDirty) {
            projectionMatrix->matrix = spt_make_perspective_matrix(registry.get<spt_perspective_camera>(entity.id));
            projectionMatrix->isDirty = false;
        }
        return projectionMatrix->matrix;
    }
    return matrix_identity_float4x4;
}

}

spt_perspective_camera spt_make_perspective_camera(spt_entity entity, float fovy, float aspectRatio, float near, float far) {
    auto& registry = static_cast<spt::Scene*>(entity.sceneHandle)->registry;
    const auto& camera = registry.emplace<spt_perspective_camera>(entity.id, fovy, aspectRatio, near, far);
    registry.emplace<spt::projection_matrix>(entity.id, spt_make_perspective_matrix(camera), false);
    return camera;
}

spt_perspective_camera spt_update_perspective_camera_aspect_ratio(spt_entity entity, float aspectRatio) {
    auto& registry = static_cast<spt::Scene*>(entity.sceneHandle)->registry;
    registry.patch<spt::projection_matrix>(entity.id, [](auto& projectionMatrix) {
        projectionMatrix.isDirty = true;
    });
    return registry.patch<spt_perspective_camera>(entity.id, [aspectRatio] (auto& camera) {
        camera.aspectRatio = aspectRatio;
    });
}
