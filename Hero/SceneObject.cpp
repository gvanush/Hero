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
    
    simd::float4x4 rotationMatrix;
    
    switch (_eulerOrder) {
        case EulerOrder_xyz: {
            rotationMatrix = makeRotationXMatrix(_rotation.x) * makeRotationXMatrix(_rotation.y) * makeRotationXMatrix(_rotation.z);
            break;
        }
        case EulerOrder_xzy: {
            rotationMatrix = makeRotationXMatrix(_rotation.x) * makeRotationXMatrix(_rotation.z) * makeRotationXMatrix(_rotation.y);
            break;
        }
        case EulerOrder_yxz: {
            rotationMatrix = makeRotationXMatrix(_rotation.y) * makeRotationXMatrix(_rotation.x) * makeRotationXMatrix(_rotation.z);
            break;
        }
        case EulerOrder_yzx: {
            rotationMatrix = makeRotationXMatrix(_rotation.y) * makeRotationXMatrix(_rotation.z) * makeRotationXMatrix(_rotation.x);
            break;
        }
        case EulerOrder_zxy: {
            rotationMatrix = makeRotationXMatrix(_rotation.z) * makeRotationXMatrix(_rotation.x) * makeRotationXMatrix(_rotation.y);
            break;
        }
        case EulerOrder_zyx: {
            rotationMatrix = makeRotationXMatrix(_rotation.z) * makeRotationXMatrix(_rotation.y) * makeRotationXMatrix(_rotation.x);
            break;
        }
    }
    
    _worldMatrix = makeScaleMatrix(_scale) * rotationMatrix * makeTranslationMatrix(_position);
    
    _isWorldMatrixValid = true;
    
    return _worldMatrix;
}

}
