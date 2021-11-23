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
    
    SPTObject makeObject();
    static void destroyObject(SPTObject entity);
    
    void render(void* renderingContext);
    
    spt::Registry registry;
    MeshRenderer meshRenderer {registry};
};

inline SPTObject Scene::makeObject() {
    return SPTObject { registry.create(), this };
}

inline void Scene::destroyObject(SPTObject entity) {
    static_cast<Scene*>(entity.sceneHandle)->registry.destroy(entity.entity);
}

}
