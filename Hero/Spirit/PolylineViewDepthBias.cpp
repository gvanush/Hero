//
//  PolylineViewDepthBias.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 09.12.21.
//

#include "PolylineViewDepthBias.h"
#include "Scene.hpp"

SPTPolylineViewDepthBias SPTPolylineViewDepthBiasMake(SPTObject object, float bias, float slopeScale, float clamp) {
    return spt::Scene::getRegistry(object).emplace<SPTPolylineViewDepthBias>(object.entity, bias, slopeScale, clamp);
}
