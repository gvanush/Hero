//
//  PolylineLookDepthBias.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 09.12.21.
//

#include "PolylineLookDepthBias.h"
#include "Scene.hpp"

void SPTPolylineLookDepthBiasMake(SPTObject object, SPTPolylineLookDepthBias depthBias) {
    spt::Scene::getRegistry(object).emplace<SPTPolylineLookDepthBias>(object.entity, depthBias);
}
