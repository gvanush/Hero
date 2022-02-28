//
//  OutlineView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 19.12.21.
//

#include "OutlineView.h"
#include "Scene.hpp"

SPTOutlineView SPTOutlineViewMake(SPTObject object, SPTMeshId meshId, simd_float4 color, float thickness) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.emplace<SPTOutlineView>(object.entity, color, meshId, thickness);
}

void SPTOutlineViewDestroy(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.erase<SPTOutlineView>(object.entity);
}
