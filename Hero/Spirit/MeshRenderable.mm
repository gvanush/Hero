//
//  MeshRenderable.c
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#include "MeshRenderable.h"
#include "Scene.hpp"

SPTMeshRenderable SPTMakeMeshRenderable(SPTObject object, SPTMeshId meshId, simd_float4 color) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.emplace<SPTMeshRenderable>(object.entity, meshId, color);
}
