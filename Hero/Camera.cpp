//
//  Camera.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#include "Camera.hpp"
#include "Transform.hpp"
#include "Math.hpp"

#include <cassert>

namespace hero {

Camera::Camera(SceneObject& sceneObject, float near, float far, float aspectRatio)
: Component {sceneObject}
, _aspectRatio {aspectRatio}
, _near {near}
, _far {far} {
}

simd::float4x4 Camera::projectionMatrix() const {
    assert(_near >= 0.f);
    assert(_far >= 0.f);
    assert(_near < _far);
    assert(_aspectRatio > 0.f);
    switch (_projection) {
        case Projection_perspective: {
            assert(_fovy > 0.f);
            return makePerspectiveMatrix(_fovy, _aspectRatio, _near, _far);
        }
        case Projection_ortographic: {
            assert(_orthographicScale > 0.f);
            auto halfHeight = _orthographicScale;
            auto halfWidth = halfHeight * _aspectRatio;
            if (_aspectRatio < 1.f) {
                halfWidth = _orthographicScale;
                halfHeight = halfWidth / _aspectRatio;
            }
            return makeOrthographicMatrix(-halfWidth, halfWidth, -halfHeight, halfHeight, _near, _far);
        }
    }
}

simd::float4x4 Camera::viewMatrix() const {
    return simd::inverse(_transform->worldMatrix());
}

simd::float4x4 Camera::projectionViewMatrix() const {
    return viewMatrix() * projectionMatrix();
}

simd::float3 Camera::convertWorldToViewport(const simd::float3& point, const simd::float2& viewportSize) {
    auto pos = simd::make_float4(point, 1.f) * projectionViewMatrix();
    pos /= pos.w;
    pos = pos * makeViewportMatrix(viewportSize);
    return simd::float3 {pos.x, pos.y, pos.z};
}

simd::float3 Camera::convertViewportToWorld(const simd::float3& point, const simd::float2& viewportSize) {
    auto pos = simd::make_float4(point, 1.f) * simd::inverse(makeViewportMatrix(viewportSize)) * simd::inverse(projectionMatrix()) * _transform->worldMatrix();
    pos /= pos.w;
    return simd::float3 {pos.x, pos.y, pos.z};
}

simd::float3 Camera::convertWorldToNDC(const simd::float3& point) {
    auto ndc = simd::make_float4(point, 1.f) * projectionViewMatrix();
    ndc /= ndc.w;
    return simd::float3 {ndc.x, ndc.y, ndc.z};
}

void Camera::lookAt(const simd::float3& point, const simd::float3& up) {
    _transform->orientToRotationMatrix(makeLookAtMatrix(_transform->position(), point, up));
}

void Camera::onStart() {
    _transform = get<Transform>();
}

void Camera::onComponentWillRemove([[maybe_unused]] TypeId typeId, Component*) {
    assert(typeIdOf<Transform> != typeId);
}

}
