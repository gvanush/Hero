//
//  PolylineLookDepthBias.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 09.12.21.
//

#include "PolylineLookDepthBias.h"
#include "Scene.hpp"

SPTPolylineLookDepthBias SPTPolylineLookDepthBiasMake(SPTObject object, float bias, float slopeScale, float clamp) {
    return spt::Scene::getRegistry(object).emplace<SPTPolylineLookDepthBias>(object.entity, bias, slopeScale, clamp);
}
