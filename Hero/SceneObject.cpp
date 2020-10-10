//
//  SceneObject.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#include "SceneObject.hpp"
#include "Math.hpp"

namespace hero {

const simd::float4x4& SceneObject::worldMatrix() const {
    if (_isWorldMatrixValid) {
        return _worldMatrix;
    }
    
    _worldMatrix = makeScaleMatrix(_scale) * simd::float4x4 {orientation()} * makeTranslationMatrix(_position);
    
    _isWorldMatrixValid = true;
    
    return _worldMatrix;
}

const simd::quatf& SceneObject::orientation() const {
    
    if(_isOrientationValid) {
        return _orientation;
    }
    
    simd::float4x4 rotationMatrix;
    switch (_eulerOrder) {
        case EulerOrder_xyz: {
            rotationMatrix = makeRotationXMatrix(_rotation.x) * makeRotationYMatrix(_rotation.y) * makeRotationZMatrix(_rotation.z);
            break;
        }
        case EulerOrder_xzy: {
            rotationMatrix = makeRotationXMatrix(_rotation.x) * makeRotationZMatrix(_rotation.z) * makeRotationYMatrix(_rotation.y);
            break;
        }
        case EulerOrder_yxz: {
            rotationMatrix = makeRotationYMatrix(_rotation.y) * makeRotationXMatrix(_rotation.x) * makeRotationZMatrix(_rotation.z);
            break;
        }
        case EulerOrder_yzx: {
            rotationMatrix = makeRotationYMatrix(_rotation.y) * makeRotationZMatrix(_rotation.z) * makeRotationXMatrix(_rotation.x);
            break;
        }
        case EulerOrder_zxy: {
            rotationMatrix = makeRotationZMatrix(_rotation.z) * makeRotationXMatrix(_rotation.x) * makeRotationYMatrix(_rotation.y);
            break;
        }
        case EulerOrder_zyx: {
            rotationMatrix = makeRotationZMatrix(_rotation.z) * makeRotationYMatrix(_rotation.y) * makeRotationXMatrix(_rotation.x);
            break;
        }
    }
    
    _orientation = simd::quatf(rotationMatrix);
    _isOrientationValid = true;
    
    return _orientation;
}

void SceneObject::orientToRotationMatrix(const simd::float3x3& rotationMatrix) {
    _orientation = simd::quatf(rotationMatrix);
    _isOrientationValid = true;
    _rotation = getRotationMatrixEulerAngles(rotationMatrix, _eulerOrder);
    _isWorldMatrixValid = false;
}



}
