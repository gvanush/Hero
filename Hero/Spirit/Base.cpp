//
//  Common.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.11.21.
//

#include "Base.h"
#include "Base.hpp"
#include "Scene.hpp"

#include <entt/entt.hpp>

const SPTObject kSPTNullObject {entt::null, nullptr};

bool SPTIsNull(SPTObject object) {
    return object.sceneHandle == kSPTNullObject.sceneHandle && object.entity == kSPTNullObject.entity;
}

bool SPTIsValid(SPTObject entity) {
    return entity.sceneHandle != nullptr && static_cast<spt::Scene*>(entity.sceneHandle)->registry.valid(entity.entity);
}
