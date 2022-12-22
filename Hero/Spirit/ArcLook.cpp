//
//  ArcLook.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.12.22.
//

#include "ArcLook.h"
#include "Scene.hpp"

#include <simd/simd.h>

bool SPTArcLookEqual(SPTArcLook lhs, SPTArcLook rhs) {
    return simd_equal(lhs.color, rhs.color) && lhs.radius == rhs.radius && lhs.startAngle == rhs.startAngle && lhs.endAngle == rhs.endAngle && lhs.thickness == rhs.thickness && lhs.categories == rhs.categories;
}

void SPTArcLookMake(SPTObject object, SPTArcLook polylineLook) {
    spt::Scene::getRegistry(object).emplace<SPTArcLook>(object.entity, polylineLook);
}

void SPTArcLookUpdate(SPTObject object, SPTArcLook polylineLook) {
    spt::Scene::getRegistry(object).get<SPTArcLook>(object.entity) = polylineLook;
}

void SPTArcLookDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<SPTArcLook>(object.entity);
}

SPTArcLook SPTArcLookGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTArcLook>(object.entity);
}

const SPTArcLook* _Nullable SPTArcLookTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTArcLook>(object.entity);
}

bool SPTArcLookExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTArcLook>(object.entity);
}
