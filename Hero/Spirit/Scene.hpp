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
    
    SPTObject makeObject();
    static void destroyObject(SPTObject entity);
    
    void onPrerender();
    void render(void* renderingContext);
    
    static Registry& getRegistry(SPTObject object) {
        return static_cast<spt::Scene*>(object.sceneHandle)->registry;
    }
    
    Registry registry;
    Renderer meshRenderer {registry};
    Transformation::GroupType transformationGroup;
};

}
