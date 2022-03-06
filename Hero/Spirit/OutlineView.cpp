//
//  OutlineView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 19.12.21.
//

#include "OutlineView.h"
#include "Scene.hpp"

SPTOutlineView SPTOutlineViewMake(SPTObject object, SPTMeshId meshId, simd_float4 color, float thickness) {
    return spt::Scene::getRegistry(object).emplace<SPTOutlineView>(object.entity, color, meshId, thickness);
}

void SPTOutlineViewDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<SPTOutlineView>(object.entity);
}
