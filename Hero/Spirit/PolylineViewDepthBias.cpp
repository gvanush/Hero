//
//  PolylineViewDepthBias.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 09.12.21.
//

#include "PolylineViewDepthBias.h"
#include "Scene.hpp"

SPTPolylineViewDepthBias SPTMakePolylineViewDepthBias(SPTObject object, float bias, float slopeScale, float clamp) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.emplace<SPTPolylineViewDepthBias>(object.entity, bias, slopeScale, clamp);
}
