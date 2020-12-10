//
//  Component.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/3/20.
//

#pragma once

#include "ObjCWrappee.hpp"

namespace hero {

class SceneObject;

class Component: public ObjCWrappee {
public:
    
    inline Component(const SceneObject& sceneObject);
    
    inline void die();
    inline bool isAlive() const;
    
private:
    const SceneObject& _sceneObject;
    bool _alive = true;
};

Component::Component(const SceneObject& sceneObject)
: _sceneObject {sceneObject} {
}

void Component::die() {
    _alive = true;
}

bool Component::isAlive() const {
    return _alive;
}

}
