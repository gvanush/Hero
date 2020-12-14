//
//  SceneObject.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

#include "Component.hpp"
#include "TypeId.hpp"

#include <unordered_map>

namespace hero {

class Scene;

class SceneObject {
public:
    
    SceneObject(Scene& scene);
    ~SceneObject();
    
    template <typename CT, typename... Args>
    inline CT* set(Args&&... args);
    
    template <typename CT>
    inline void remove();
    
    template <typename CT>
    inline CT* get() const;
    
    inline Scene& scene() const;
    
private:
    CompositeComponent _compositeComponent;
    Scene& _scene;
    bool _active = false;
};

template <typename CT, typename... Args>
CT* SceneObject::set(Args&&... args) {
    return _compositeComponent.setChild<CT>(std::forward<Args>(args)...);
}

template <typename CT>
void SceneObject::remove() {
    _compositeComponent.removeChild<CT>();
}

template <typename CT>
CT* SceneObject::get() const {
    return _compositeComponent.getChild<CT>();
}

Scene& SceneObject::scene() const {
    return _scene;
}

}
