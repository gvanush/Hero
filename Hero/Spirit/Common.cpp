//
//  Common.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#include "Common.h"
#include "Scene.hpp"

#include <entt/entt.hpp>

const spt_entity spt_k_null_entity {entt::null, nullptr};

bool spt_is_valid(spt_entity entity) {
    return entity.sceneHandle != nullptr && static_cast<spt::Scene*>(entity.sceneHandle)->registry.valid(entity.id);
}
