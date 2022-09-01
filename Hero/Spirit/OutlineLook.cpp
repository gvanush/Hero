//
//  OutlineLook.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 19.12.21.
//

#include "OutlineLook.h"
#include "Scene.hpp"


bool SPTOutlineLookEqual(SPTOutlineLook lhs, SPTOutlineLook rhs) {
    return simd_equal(lhs.color, rhs.color) && lhs.thickness == rhs.thickness && lhs.categories == rhs.categories;
}

void SPTOutlineLookMake(SPTObject object, SPTOutlineLook outlineLook) {
    spt::Scene::getRegistry(object).emplace<SPTOutlineLook>(object.entity, outlineLook);
}

void SPTOutlineLookUpdate(SPTObject object, SPTOutlineLook newOutlineLook) {
    spt::Scene::getRegistry(object).get<SPTOutlineLook>(object.entity) = newOutlineLook;
}

void SPTOutlineLookDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<SPTOutlineLook>(object.entity);
}

SPTOutlineLook SPTOutlineLookGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTOutlineLook>(object.entity);
}

const SPTOutlineLook* _Nullable SPTOutlineLookTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTOutlineLook>(object.entity);
}

bool SPTOutlineLookExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTOutlineLook>(object.entity);
}
