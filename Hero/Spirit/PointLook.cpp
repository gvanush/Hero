//
//  PointLook.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 04.03.22.
//

#include "PointLook.h"
#include "Scene.hpp"

#include <simd/simd.h>


bool SPTPointLookEqual(SPTPointLook lhs, SPTPointLook rhs) {
    return simd_equal(lhs.color, rhs.color) && lhs.size == rhs.size && lhs.categories == rhs.categories;
}

void SPTPointLookMake(SPTObject object, SPTPointLook pointLook) {
    spt::Scene::getRegistry(object).emplace<SPTPointLook>(object.entity, pointLook);
}

void SPTPointLookUpdate(SPTObject object, SPTPointLook pointLook) {
    spt::Scene::getRegistry(object).get<SPTPointLook>(object.entity) = pointLook;
}

void SPTPointLookDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<SPTPointLook>(object.entity);
}

SPTPointLook SPTPointLookGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTPointLook>(object.entity);
}

const SPTPointLook* _Nullable SPTPointLookTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTPointLook>(object.entity);
}

bool SPTPointLookExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTPointLook>(object.entity);
}
