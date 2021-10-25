//
//  Transform.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/8/20.
//

#include "Transform.hpp"
#include "Math.hpp"

namespace hero {

const simd::float4x4& Transform::worldMatrix() const {
    if (_isWorldMatrixValid) {
        return _worldMatrix;
    }
    
    _worldMatrix = makeScaleMatrix(_scale) * simd::float4x4 {orientation()} * makeTranslationMatrix(_position);
    
    _isWorldMatrixValid = true;
    
    return _worldMatrix;
}

const simd::quatf& Transform::orientation() const {
    
    if(_isOrientationValid) {
        return _orientation;
    }
    
    simd::float4x4 rotationMatrix;
    switch (_rotationMode) {
        case RotationMode_xyz: {
            rotationMatrix = makeRotationXMatrix(_rotation.x) * makeRotationYMatrix(_rotation.y) * makeRotationZMatrix(_rotation.z);
            break;
        }
        case RotationMode_xzy: {
            rotationMatrix = makeRotationXMatrix(_rotation.x) * makeRotationZMatrix(_rotation.z) * makeRotationYMatrix(_rotation.y);
            break;
        }
        case RotationMode_yxz: {
            rotationMatrix = makeRotationYMatrix(_rotation.y) * makeRotationXMatrix(_rotation.x) * makeRotationZMatrix(_rotation.z);
            break;
        }
        case RotationMode_yzx: {
            rotationMatrix = makeRotationYMatrix(_rotation.y) * makeRotationZMatrix(_rotation.z) * makeRotationXMatrix(_rotation.x);
            break;
        }
        case RotationMode_zxy: {
            rotationMatrix = makeRotationZMatrix(_rotation.z) * makeRotationXMatrix(_rotation.x) * makeRotationYMatrix(_rotation.y);
            break;
        }
        case RotationMode_zyx: {
            rotationMatrix = makeRotationZMatrix(_rotation.z) * makeRotationYMatrix(_rotation.y) * makeRotationXMatrix(_rotation.x);
            break;
        }
    }
    
    _orientation = simd::quatf(rotationMatrix);
    _isOrientationValid = true;
    
    return _orientation;
}

void Transform::orientToRotationMatrix(const simd::float3x3& rotationMatrix) {
    _orientation = simd::quatf(rotationMatrix);
    _isOrientationValid = true;
    _rotation = getRotationMatrixEulerAngles(rotationMatrix, _rotationMode);
    _isWorldMatrixValid = false;
}

}
