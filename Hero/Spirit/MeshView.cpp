//
//  MeshView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#include "MeshView.h"
#include "Scene.hpp"

SPTMeshView SPTMakeMeshView(SPTObject object, SPTMeshId meshId, simd_float4 color) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.emplace<SPTMeshView>(object.entity, color, meshId);
}
