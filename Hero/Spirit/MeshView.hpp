//
//  MeshView.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#pragma once

#include "Base.h"
#include "Base.hpp"

#include <vector>

namespace spt {

void makeBlinnPhongMeshViews(spt::Registry& registry, std::vector<SPTEntity> entities, SPTMeshId meshId, simd_float4 color, float specularRoughness);

}

