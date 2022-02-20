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
#include "ComponentUpdateNotifier.hpp"
#include "Transformation.hpp"
#include "Transformation.h"
#include "Generator.hpp"

#include <entt/entt.hpp>
#include <tuple>

namespace spt {

struct Scene {
    
    Scene();
    ~Scene();
    
    SPTObject makeObject();
    static void destroyObject(SPTObject entity);
    
    void render(void* renderingContext);
    
    Registry registry;
    
    Renderer meshRenderer {registry};
        
};

inline SPTObject Scene::makeObject() {
    return SPTObject { registry.create(), this };
}

inline void Scene::destroyObject(SPTObject entity) {
    static_cast<Scene*>(entity.sceneHandle)->registry.destroy(entity.entity);
}

}
