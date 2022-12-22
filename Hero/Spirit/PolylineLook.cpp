//
//  PolylineLook.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.12.21.
//

#include "PolylineLook.h"
#include "Scene.hpp"

#include <simd/simd.h>

bool SPTPolylineLookEqual(SPTPolylineLook lhs, SPTPolylineLook rhs) {
    return simd_equal(lhs.color, rhs.color) && lhs.polylineId == rhs.polylineId && lhs.thickness == rhs.thickness && lhs.categories == rhs.categories;
}

void SPTPolylineLookMake(SPTObject object, SPTPolylineLook polylineLook) {
    spt::Scene::getRegistry(object).emplace<SPTPolylineLook>(object.entity, polylineLook);
}

void SPTPolylineLookUpdate(SPTObject object, SPTPolylineLook polylineLook) {
    spt::Scene::getRegistry(object).get<SPTPolylineLook>(object.entity) = polylineLook;
}

void SPTPolylineLookDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<SPTPolylineLook>(object.entity);
}

SPTPolylineLook SPTPolylineLookGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTPolylineLook>(object.entity);
}

const SPTPolylineLook* _Nullable SPTPolylineLookTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTPolylineLook>(object.entity);
}

bool SPTPolylineLookExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTPolylineLook>(object.entity);
}
