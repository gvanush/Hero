//
//  SceneObject.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

#include "ObjCWrappee.hpp"
#include "Transform.hpp"
#include "GeometryUtils_Common.h"

#include <simd/simd.h>

namespace hero {

class SceneObject: public ObjCWrappee {
public:
    
    inline Transform* transform() const;
    ~SceneObject() {
        delete _transform;
        _transform = nullptr;
    }
    
private:
    Transform* _transform = new Transform {};
};

Transform* SceneObject::transform() const {
    return _transform;
}

}
