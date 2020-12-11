//
//  SceneObject.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

#include "Component.hpp"
#include "Transform.hpp"
#include "TypeId.hpp"

#include <unordered_map>

namespace hero {

class SceneObject {
public:
    
    SceneObject();
    ~SceneObject();
    
    template <typename CT>
    inline CT* set();
    
    template <typename CT>
    inline void remove();
    
    template <typename CT>
    inline CT* get() const;
    
    static SceneObject* makeBasic();
    
private:
    CompositeComponent _compositeComponent;
    bool _active = false;
};

template <typename CT>
CT* SceneObject::set() {
    return _compositeComponent.setChild<CT>();
}

template <typename CT>
void SceneObject::remove() {
    _compositeComponent.removeChild<CT>();
}

template <typename CT>
CT* SceneObject::get() const {
    return _compositeComponent.getChild<CT>();
}

}
