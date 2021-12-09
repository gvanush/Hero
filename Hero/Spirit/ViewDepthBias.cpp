//
//  ViewDepthBias.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 09.12.21.
//

#include "ViewDepthBias.h"
#include "Scene.hpp"

SPTViewDepthBias SPTMakeViewDepthBias(SPTObject object, float bias, float slopeScale, float clamp) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.emplace<SPTViewDepthBias>(object.entity, bias, slopeScale, clamp);
}
