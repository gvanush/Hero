//
//  MeshView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#include "MeshView.h"
#include "MeshView.hpp"
#include "Scene.hpp"

SPTMeshView SPTMeshViewMakePlainColor(SPTObject object, SPTMeshId meshId, simd_float4 color) {
    return spt::Scene::getRegistry(object).emplace<SPTMeshView>(object.entity, color, SPTMeshShadingPlainColor, meshId);
}

SPTMeshView SPTMeshViewMakeBlinnPhong(SPTObject object, SPTMeshId meshId, simd_float4 color, float specularRoughness) {
    auto& registry = spt::Scene::getRegistry(object);
    auto& meshView = registry.emplace<SPTMeshView>(object.entity, color, SPTMeshShadingBlinnPhong, meshId);
    meshView.blinnPhong.specularRoughness = specularRoughness;
    return meshView;
}

SPTMeshView SPTMeshViewGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTMeshView>(object.entity);
}
