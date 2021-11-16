//
//  Scene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "Base.h"
#include "Base.hpp"
#include "MeshRenderer.hpp"

#include <entt/entt.hpp>

namespace spt {

struct Scene {
    
    SPTObject makeEntity();
    static void destroyEntity(SPTObject entity);
    
    void update(void* renderingContext);
    
    spt::Registry registry;
    MeshRenderer meshRenderer;
};

inline SPTObject Scene::makeEntity() {
    return SPTObject { registry.create(), this };
}

inline void Scene::destroyEntity(SPTObject entity) {
    static_cast<Scene*>(entity.sceneHandle)->registry.destroy(entity.entity);
}

}
