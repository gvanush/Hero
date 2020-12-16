//
//  Camera.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

#include "Component.hpp"
#include "GeometryUtils_Common.h"
#include "Math.hpp"

#include <simd/simd.h>

namespace hero {

class Transform;

class Camera: public Component {
public:
    
    Camera(SceneObject& sceneObject, float near, float far, float aspectRatio);
    
    inline void setAspectRatio(float aspectRatio);
    inline float aspectRatio() const;
    
    inline void setFovy(float fovy);
    inline float fovy() const;
    
    inline void setOrthographicScale(float scale);
    inline float orthographicScale() const;
    
    inline void setNear(float near);
    inline float near() const;
    
    inline void setFar(float far);
    inline float far() const;
    
    inline void setProjection(Projection projection);
    inline Projection projection() const;
    
    simd::float4x4 projectionMatrix() const;
    simd::float4x4 viewMatrix() const;
    simd::float4x4 projectionViewMatrix() const;
    
    simd::float3 convertWorldToViewport(const simd::float3& point, const simd::float2& viewportSize);
    simd::float3 convertViewportToWorld(const simd::float3& point, const simd::float2& viewportSize);
    
    simd::float3 convertWorldToNDC(const simd::float3& point);
    
    void lookAt(const simd::float3& point, const simd::float3& up = kUp);
    
    void onStart() override;
    void onComponentWillRemove(ComponentTypeInfo typeInfo, Component *component) override;
    
    static constexpr auto category = ComponentCategory::basic;
    
private:
    Transform* _transform = nullptr;
    float _aspectRatio;
    float _fovy = M_PI_4;
    float _orthographicScale = 1.f;
    float _near;
    float _far;
    Projection _projection = Projection_perspective;
};

void Camera::setAspectRatio(float aspectRatio) {
    _aspectRatio = aspectRatio;
}

float Camera::aspectRatio() const {
    return _aspectRatio;
}

void Camera::setFovy(float fovy) {
    _fovy = fovy;
}

float Camera::fovy() const {
    return _fovy;
}

void Camera::setOrthographicScale(float scale) {
    _orthographicScale = scale;
}

float Camera::orthographicScale() const {
    return _orthographicScale;
}

void Camera::setNear(float near) {
    _near = near;
}

float Camera::near() const {
    return _near;
}

void Camera::setFar(float far) {
    _far = far;
}

float Camera::far() const {
    return _far;
}

void Camera::setProjection(Projection projection) {
    _projection = projection;
}

Projection Camera::projection() const {
    return _projection;
}

}
