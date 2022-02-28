//
//  MeshView.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#pragma once

#include "Base.h"
#include "Base.hpp"
#include "MeshView.h"

#include <vector>

namespace spt {

namespace MeshView {

template <typename It>
void makeBlinnPhong(spt::Registry& registry, It beginEntity, It endEntity, SPTMeshId meshId, simd_float4 color, float specularRoughness) {
    SPTMeshView meshView {color, SPTMeshShadingBlinnPhong, meshId};
    meshView.blinnPhong.specularRoughness = specularRoughness;
    registry.insert(beginEntity, endEntity, meshView);
}

template <typename It>
void update(spt::Registry& registry, It beginEntity, It endEntity, SPTMeshId meshId) {
    auto updater = [meshId] (auto& meshView) {
        meshView.meshId = meshId;
    };
    for(auto it = beginEntity; it != endEntity; ++it) {
        registry.patch<SPTMeshView>(*it, updater);
    }
}

}

}

