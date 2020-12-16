//
//  RemovedComponentRegistry.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/12/20.
//

#include "RemovedComponentRegistry.hpp"
#include "Component.hpp"
#include "Scene.hpp"
#include "SceneObject.hpp"

#include <cassert>

namespace hero {

void RemovedComponentRegistry::addComponent(Component* component) {
    assert(component->isRemoved());
    const auto& scene = component->sceneObject().scene();
    _components[&scene].emplace_back(scene.stepNumber(), component);
}

void RemovedComponentRegistry::destroyComponents(const Scene& scene, StepNumber stepNumber) {
    auto it = _components.find(&scene);
    if (it == _components.end()) {
        return;
    }
    auto& sceneComponents = it->second;
    auto rit = std::remove_if(sceneComponents.begin(), sceneComponents.end(), [stepNumber] (const auto& item) {
        if (item.first == stepNumber) {
            delete item.second;
            return true;
        }
        return false;
    });
    sceneComponents.erase(rit, sceneComponents.end());
}

void RemovedComponentRegistry::destroyComponents(const Scene& scene) {
    auto it = _components.find(&scene);
    if (it == _components.end()) {
        return;
    }
    for(const auto& item: it->second) {
        delete item.second;
    }
}

}
