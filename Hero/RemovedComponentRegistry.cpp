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
    _components[component->sceneObject().scene().stepNumber()].push_back(component);
}

void RemovedComponentRegistry::destroyComponents(Scene& scene, StepNumber stepNumber) {
    auto it = _components.find(stepNumber);
    if (it == _components.end()) {
        return;
    }
    for (auto component: it->second) {
        delete component;
    }
    _components.erase(it);
}

}
