//
//  Scene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#pragma once

#include "Common.h"
#include "MeshRenderer.hpp"

#include <entt/entt.hpp>

namespace spt {

struct Scene {
public:
    
    spt_entity makeEntity();
    static void destroyEntity(spt_entity entity);
    
    void update(void* renderingContext);
    
private:
    entt::basic_registry<spt_entity_id> registry;
    MeshRenderer meshRenderer;
};

inline spt_entity Scene::makeEntity() {
    return spt_entity { registry.create(), this };
}

inline void Scene::destroyEntity(spt_entity entity) {
    static_cast<Scene*>(entity.sceneHandle)->registry.destroy(entity.id);
}

}
