//
//  PolylineLookDepthBias.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 09.12.21.
//

#include "LineLookDepthBias.h"
#include "Scene.hpp"

void SPTLineLookDepthBiasMake(SPTObject object, SPTLineLookDepthBias depthBias) {
    spt::Scene::getRegistry(object).emplace<SPTLineLookDepthBias>(object.entity, depthBias);
}
