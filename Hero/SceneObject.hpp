//
//  SceneObject.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

#include "Object.hpp"
#include "Geometry.h"

#include <simd/simd.h>

namespace hero {

class SceneObject: public Object {
public:
    
    inline void setPosition(const simd::float3& pos);
    inline void setPosition(float x, float y, float z);
    inline const simd::float3& position() const;
    
    inline void setScale(const simd::float3& scale);
    inline const simd::float3& scale() const;
    
    inline void setRotation(const simd::float3& rotation);
    inline const simd::float3& rotation() const;
    
    inline void setEulerOrder(EulerOrder eulerOrder);
    inline EulerOrder eulerOrder() const;
    
    const simd::quatf& orientation() const;
    const simd::float4x4& worldMatrix() const;
    
protected:
    void orientToRotationMatrix(const simd::float3x3& rotationMatrix);
    
private:
    mutable simd::float4x4 _worldMatrix {1};
    mutable simd::quatf _orientation {};
    simd::float3 _position {};
    simd::float3 _scale {1.f, 1.f, 1.f};
    simd::float3 _rotation {};
    EulerOrder _eulerOrder = EulerOrder_yxz;
    mutable bool _isWorldMatrixValid = true;
    mutable bool _isOrientationValid = true;
};

void SceneObject::setPosition(const simd::float3& pos) {
    _isWorldMatrixValid = false;
    _position = pos;
}

void SceneObject::setPosition(float x, float y, float z) {
    setPosition(simd::float3 {x, y, z});
}

const simd::float3& SceneObject::position() const {
    return _position;
}

void SceneObject::setScale(const simd::float3& scale) {
    _isWorldMatrixValid = false;
    _scale = scale;
}

const simd::float3& SceneObject::scale() const {
    return _scale;
}

void SceneObject::setRotation(const simd::float3& rotation) {
    _isWorldMatrixValid = false;
    _isOrientationValid = false;
    _rotation = rotation;
}

const simd::float3& SceneObject::rotation() const {
    return _rotation;
}

void SceneObject::setEulerOrder(EulerOrder eulerOrder) {
    _isWorldMatrixValid = false;
    _isOrientationValid = false;
    _eulerOrder = eulerOrder;
}

EulerOrder SceneObject::eulerOrder() const {
    return _eulerOrder;
}

}
