//
//  RemovedComponentRegistry.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/12/20.
//

#pragma once

#include "Singleton.hpp"
#include "GraphicsCoreUtils.hpp"

#include <unordered_map>
#include <vector>

namespace hero {

class Component;
class Scene;

class RemovedComponentRegistry: public Singleton<RemovedComponentRegistry> {
public:
    
    void addComponent(Component* component);
    
    void destroyComponents(Scene& scene, StepNumber stepNumber);
    
private:
    std::unordered_map<StepNumber, std::vector<Component*>> _components;
};

}
