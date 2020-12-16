//
//  RemovedComponentRegistry.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/12/20.
//

#pragma once

#include "GraphicsCoreUtils.hpp"

#include <unordered_map>
#include <vector>

namespace hero {

class Component;
class Scene;

class RemovedComponentRegistry {
public:
    
    void addComponent(Component* component);
    
    void destroyComponents(const Scene* scene, StepNumber stepNumber);
    void destroyComponents(const Scene* scene);
    
    static RemovedComponentRegistry& shared() {
        static RemovedComponentRegistry obj;
        return obj;
    }
    
private:
    
    RemovedComponentRegistry() = default;
    
    RemovedComponentRegistry(const RemovedComponentRegistry&) = delete;
    RemovedComponentRegistry& operator=(const RemovedComponentRegistry&) = delete;
    
    std::unordered_map<const Scene*, std::vector<std::pair<StepNumber, Component*>>> _components;
};

}
