//
//  Common.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#include "Base.h"
#include "Scene.hpp"

#include <entt/entt.hpp>

const SPTObject kSPTNullObject {entt::null, nullptr};

bool SPTIsValid(SPTObject entity) {
    return entity.sceneHandle != nullptr && static_cast<spt::Scene*>(entity.sceneHandle)->registry.valid(entity.entity);
}
