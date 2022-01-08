//
//  PolylineView.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.12.21.
//

#include "PolylineView.h"
#include "Scene.hpp"

SPTPolylineView SPTMakePolylineView(SPTObject object, SPTPolylineId polylineId, simd_float4 color, float thickness) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.emplace<SPTPolylineView>(object.entity, color, polylineId, thickness);
}