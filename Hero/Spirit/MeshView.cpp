//
//  MeshView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#include "MeshView.h"
#include "Scene.hpp"

SPTMeshView SPTMakePlainColorMeshView(SPTObject object, SPTMeshId meshId, simd_float4 color) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.emplace<SPTMeshView>(object.entity, color, SPTMeshShadingPlainColor, meshId);
}

SPTMeshView SPTMakeBlinnPhongMeshView(SPTObject object, SPTMeshId meshId, simd_float4 color, float specularRoughness) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    auto& meshView = registry.emplace<SPTMeshView>(object.entity, color, SPTMeshShadingBlinnPhong, meshId);
    meshView.blinnPhong.specularRoughness = specularRoughness;
    return meshView;
}

SPTMeshView SPTGetMeshView(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<SPTMeshView>(object.entity);
}