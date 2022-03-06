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

const SPTEntity kSPTNullEntity {entt::null};
const SPTObject kSPTNullObject {kSPTNullEntity, nullptr};

bool SPTIsNull(SPTObject object) {
    return object.sceneHandle == kSPTNullObject.sceneHandle && object.entity == kSPTNullObject.entity;
}

bool SPTIsValid(SPTObject object) {
    return object.sceneHandle != nullptr && spt::Scene::getRegistry(object).valid(object.entity);
}

bool SPTObjectSameAsObject(SPTObject object1, SPTObject object2) {
    return object1.sceneHandle == object2.sceneHandle && object1.entity == object2.entity;
}
