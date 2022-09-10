//
//  Scene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "Base.h"
#include "Base.hpp"
#include "Renderer.hpp"
#include "Transformation.hpp"

#include <entt/entt.hpp>
#include <tuple>

namespace spt {

struct Scene {
    
    Scene();
    ~Scene();
    
    void onPrerender();
    void render(void* renderingContext);
    
    static Registry& getRegistry(SPTHandle sceneHandle) {
        return static_cast<spt::Scene*>(sceneHandle)->registry;
    }
    
    static Registry& getRegistry(SPTObject object) {
        return getRegistry(object.sceneHandle);
    }
    
    Registry registry;
    Renderer renderer {registry};
    Transformation::GroupType transformationGroup;
};

}
