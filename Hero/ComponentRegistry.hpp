//
//  ComponentRegistry.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/4/20.
//

#pragma once

#include "ComponentUtils.hpp"

#include <vector>
#include <memory>
#include <algorithm>
#include <assert>

namespace hero {

class SceneObject__;

template <typename T>
class ComponentRegistry {
public:
    
    template <typename... Args>
    T* createCompoent(SceneObject__& sceneObject, Args&&... args);
    
    void onFrameStart();
    void onUpdate();
    void onRender();
    
    static ComponentRegistry& shared();
    
private:
    ComponentRegistry() = default;
    
    std::vector<T*> _newComponents;
    std::vector<T*> _components;
};

template <typename T>
template <typename... Args>
T* ComponentRegistry<T>::createCompoent(SceneObject__& sceneObject, Args&&... args) {
    return _newComponents.emplace_back(new T {sceneObject, std::forward<Args>(args)...});
}

template <typename T>
void ComponentRegistry<T>::onFrameStart() {
    
    auto initialSize = _components.size();
    
    std::copy_if(_newComponents.begin(), _newComponents.end(), std::back_inserter(_components), [] (auto newComp) {
        assert(newComp->parent());
        if(newComp->parent()) {
            newComp->_state = ComponentState::active;
            return true;
        }
        return false;
    });
    _newComponents.clear();
    
    // TODO
    if constexpr(false) {
        for(auto it = _components.begin() + initialSize; it != _components.end(); ++it) {
            (*it)->onEnter();
        }
    }
}

template <typename T>
void ComponentRegistry<T>::onUpdate() {
    
}

template <typename T>
void ComponentRegistry<T>::onRender() {
    
}

}
