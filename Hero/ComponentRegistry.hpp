//
//  ComponentRegistry.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/4/20.
//

#pragma once

#include "Singleton.hpp"
#include "GraphicsCoreUtils.hpp"
#include "RemovedComponentRegistry.hpp"

#include <vector>

namespace hero {

class SceneObject;

namespace _internal {

// MARK: ComponentRegistryImpl
template <typename CT, ComponentCategory CC>
class ComponentRegistryImpl: public Singleton<ComponentRegistryImpl<CT, CC>> {
public:
    
    template <typename... Args>
    CT* createCompoent(const SceneObject& sceneObject, Args&&... args) {
        return new CT {sceneObject, std::forward<Args>(args)...};
    }
    
    void removeCompoent(CT* component);
    
};

template <typename CT, ComponentCategory CC>
void ComponentRegistryImpl<CT, CC>::removeCompoent(CT* component) {
    RemovedComponentRegistry::shared().addComponent(component);
}

template <ComponentCategory C>
class ComponentRegistryImpl<Component, C>;

template <ComponentCategory C>
class ComponentRegistryImpl<CompositeComponent, C>;

// MARK: Renderer ComponentRegistryImpl
template <typename CT>
class ComponentRegistryImpl<CT, ComponentCategory::renderer>: public Singleton<ComponentRegistryImpl<CT, ComponentCategory::renderer>> {
public:
    
    template <typename... Args>
    CT* createCompoent(const SceneObject& sceneObject, Args&&... args);
    
    void removeCompoent(CT* component);
    
    void cleanRemovedComponents();
    
    void update();
    
private:
    std::vector<CT*> _components;
    bool _unlocked = true;
};

template <typename CT>
template <typename... Args>
CT* ComponentRegistryImpl<CT, ComponentCategory::renderer>::createCompoent(const SceneObject& sceneObject, Args&&... args) {
    assert(_unlocked);
    auto component = new CT {sceneObject, std::forward<Args>(args)...};
    _components.push_back(component);
    return component;
}

template <typename CT>
void ComponentRegistryImpl<CT, ComponentCategory::renderer>::removeCompoent(CT* component) {
    RemovedComponentRegistry::shared().addComponent(component);
}

template <typename CT>
void ComponentRegistryImpl<CT, ComponentCategory::renderer>::cleanRemovedComponents() {
    auto rit = std::remove_if(_components.begin(), _components.end(), [] (const auto component) {
        return component->isRemoved();
    });
    _components.erase(rit, _components.end());
}

template <typename CT>
void ComponentRegistryImpl<CT, ComponentCategory::renderer>::update() {
    
    _unlocked = false;
    for(auto component: _components) {
        assert(component->isActive());
        component->render();
    }
    _unlocked = true;
}

} // namespace _internal

template <typename CT>
using ComponentRegistry = _internal::ComponentRegistryImpl<CT, CT::category>;

}
