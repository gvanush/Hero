//
//  ComponentRegistry.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/4/20.
//

#pragma once

#include "GraphicsCoreUtils.hpp"
#include "GeometryUtils_Common.h"

#include <unordered_map>
#include <vector>
#include <array>

namespace hero {

class SceneObject;
class Scene;

namespace _internal {

// MARK: ComponentRegistryImpl
template <typename CT, ComponentCategory CC>
class ComponentRegistryImpl {
public:
    
    template <typename... Args>
    CT* createCompoent(SceneObject& sceneObject, Args&&... args);
    
    static ComponentRegistryImpl& shared() {
        static ComponentRegistryImpl obj;
        return obj;
    }
    
private:
    ComponentRegistryImpl() = default;
    ComponentRegistryImpl(const ComponentRegistryImpl&) = delete;
    ComponentRegistryImpl& operator=(const ComponentRegistryImpl&) = delete;

};

template <typename CT, ComponentCategory CC>
template <typename... Args>
CT* ComponentRegistryImpl<CT, CC>::createCompoent(SceneObject& sceneObject, Args&&... args) {
    return new CT {sceneObject, std::forward<Args>(args)...};
}

template <ComponentCategory C>
class ComponentRegistryImpl<Component, C>;

template <ComponentCategory C>
class ComponentRegistryImpl<CompositeComponent, C>;

// MARK: Renderer ComponentRegistryImpl
template <typename CT>
class ComponentRegistryImpl<CT, ComponentCategory::renderer> {
public:
    
    template <typename... Args>
    CT* createCompoent(SceneObject& sceneObject, Args&&... args);
    
    void cleanRemovedComponents(const Scene* scene);
    void cleanComponents(const Scene* scene);
    
    void update(const Scene* scene, Layer layer, void* renderingContext);
    
    CT* raycast(const Scene* scene, const Ray& ray);
    
    static ComponentRegistryImpl& shared() {
        static ComponentRegistryImpl obj;
        return obj;
    }
    
private:
    
    ComponentRegistryImpl();
    ComponentRegistryImpl(const ComponentRegistryImpl&) = delete;
    ComponentRegistryImpl& operator=(const ComponentRegistryImpl&) = delete;
    
    std::unordered_map<const Scene*, std::array<std::vector<CT*>, _kLayerCount>> _components;
    bool _unlocked = true;
};

template <typename CT>
ComponentRegistryImpl<CT, ComponentCategory::renderer>::ComponentRegistryImpl() {
    CT::setup();
}

template <typename CT>
template <typename... Args>
CT* ComponentRegistryImpl<CT, ComponentCategory::renderer>::createCompoent(SceneObject& sceneObject, Args&&... args) {
    assert(_unlocked);
    auto component = new CT {sceneObject, std::forward<Args>(args)...};
    _components[&component->scene()][component->layer()].push_back(component);
    return component;
}

template <typename CT>
void ComponentRegistryImpl<CT, ComponentCategory::renderer>::cleanRemovedComponents(const Scene* scene) {
    auto it = _components.find(scene);
    if (it == _components.end()) {
        return;
    }
    
    for(auto& layerComponents: it->second) {
        auto rit = std::remove_if(layerComponents.begin(), layerComponents.end(), [] (const auto component) {
            return component->isRemoved();
        });
        layerComponents.erase(rit, layerComponents.end());
    }
}

template <typename CT>
void ComponentRegistryImpl<CT, ComponentCategory::renderer>::cleanComponents(const Scene* scene) {
    auto it = _components.find(scene);
    if (it == _components.end()) {
        return;
    }
    _components.erase(it);
}

template <typename CT>
void ComponentRegistryImpl<CT, ComponentCategory::renderer>::update(const Scene* scene, Layer layer, void* renderingContext) {
    
    CT::preRender(renderingContext);
    
    auto it = _components.find(scene);
    if (it == _components.end()) {
        return;
    }

    _unlocked = false;
    for(auto component: it->second[layer]) {
        assert(component->isActive());
        component->render(renderingContext);
    }
    _unlocked = true;
}

template <typename CT>
CT* ComponentRegistryImpl<CT, ComponentCategory::renderer>::raycast(const Scene* scene, const Ray& ray) {
    
    auto it = _components.find(scene);
    if (it == _components.end()) {
        return nullptr;
    }
    
    CT* result = nullptr;
    float minNormDistance = std::numeric_limits<float>::max();
    
    for(auto component: it->second[kLayerContent]) {
        float normDistance;
        if (component->isActive() && component->raycast(ray, normDistance)) {
            if (minNormDistance > normDistance) {
                result = component;
                minNormDistance = normDistance;
            }
        }
    }
    return result;
}

} // namespace _internal

template <typename CT>
using ComponentRegistry = _internal::ComponentRegistryImpl<CT, CT::category>;

}
