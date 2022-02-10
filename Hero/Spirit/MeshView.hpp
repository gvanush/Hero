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

template <typename It>
void makeBlinnPhongMeshViews(spt::Registry& registry, It beginEntity, It endEntity, SPTMeshId meshId, simd_float4 color, float specularRoughness) {
    SPTMeshView meshView {color, SPTMeshShadingBlinnPhong, meshId};
    meshView.blinnPhong.specularRoughness = specularRoughness;
    registry.insert(beginEntity, endEntity, meshView);
}

void updateMeshViews(spt::Registry& registry, std::vector<SPTEntity> entities, SPTMeshId meshId);

}

