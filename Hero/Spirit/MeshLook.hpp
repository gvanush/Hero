//
//  MeshLook.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#pragma once

#include "Base.h"
#include "Base.hpp"
#include "MeshLook.h"

#include <vector>

namespace spt {

namespace MeshLook {

template <typename It>
void makeBlinnPhong(spt::Registry& registry, It beginEntity, It endEntity, SPTMeshId meshId, simd_float4 color, float specularRoughness) {
    SPTMeshLook meshLook {color, SPTMeshShadingBlinnPhong, meshId};
    meshLook.blinnPhong.specularRoughness = specularRoughness;
    registry.insert(beginEntity, endEntity, meshLook);
}

template <typename It>
void update(spt::Registry& registry, It beginEntity, It endEntity, SPTMeshId meshId) {
    auto updater = [meshId] (auto& meshLook) {
        meshLook.meshId = meshId;
    };
    for(auto it = beginEntity; it != endEntity; ++it) {
        registry.patch<SPTMeshLook>(*it, updater);
    }
}

}

}

