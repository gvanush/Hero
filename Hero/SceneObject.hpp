//
//  SceneObject.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

#include "Component.hpp"

#include <unordered_map>
#include <string>

namespace hero {

class Scene;
class SelectedObjectMarker;

class SceneObject {
public:
    
    ~SceneObject();
    
    template <typename CT, typename... Args>
    inline CT* set(Args&&... args);
    
    template <typename CT>
    inline void remove();
    
    template <typename CT>
    inline CT* get() const;
    
    inline void setName(const std::string& name);
    inline const std::string& name() const;
    
    bool isSelected() const;
    
    inline Scene& scene() const;
    
    friend class Scene;
    
private:
    
    SceneObject(Scene& scene);
    
    void start();
    void stop();
    
    CompositeComponent _compositeComponent;
    std::string _name;
    Scene& _scene;
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

void SceneObject::setName(const std::string& name) {
    _name = name;
}

const std::string& SceneObject::name() const {
    return _name;
}

Scene& SceneObject::scene() const {
    return _scene;
}

inline void SceneObject::start() {
    _compositeComponent.start();
}

inline void SceneObject::stop() {
    _compositeComponent.stop();
}

}
