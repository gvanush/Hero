//
//  Camera.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#include "Camera.hpp"
#include "Math.hpp"

#include <cassert>

namespace hero {

Camera::Camera(float near, float far, float aspectRatio)
: _aspectRatio {aspectRatio}
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
    return simd::inverse(worldMatrix());
}

simd::float4x4 Camera::projectionViewMatrix() const {
    return viewMatrix() * projectionMatrix();
}

simd::float4 Camera::convertViewportToWorld(const simd::float4& vec, const Size2& viewportSize) {
    auto result = vec * simd::inverse(makeViewportMatrix(viewportSize)) * simd::inverse(projectionMatrix()) * worldMatrix();
    result *= result.w;
    result.w = 1.f;
    return result;
}

}
