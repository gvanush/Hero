//
//  PolylineView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.12.21.
//

#include "PolylineView.h"
#include "Scene.hpp"

SPTPolylineView SPTPolylineViewMake(SPTObject object, SPTPolylineId polylineId, simd_float4 color, float thickness) {
    return spt::Scene::getRegistry(object).emplace<SPTPolylineView>(object.entity, color, polylineId, thickness);
}
