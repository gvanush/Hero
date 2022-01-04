//
//  PlainColorMeshView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#include "PlainColorMeshView.h"
#include "Scene.hpp"

SPTPlainColorMeshView SPTMakePlainColorMeshView(SPTObject object, SPTMeshId meshId, simd_float4 color) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.emplace<SPTPlainColorMeshView>(object.entity, color, meshId);
}

SPTPlainColorMeshView SPTGetPlainColorMeshView(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<SPTPlainColorMeshView>(object.entity);
}
