//
//  Position.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Position.h"
#include "Scene.hpp"
#include "ComponentListenerUtil.hpp"


void SPTMakePosition(SPTObject object, SPTPosition position) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    registry.emplace<SPTPosition>(object.entity, position);
}

void SPTUpdatePosition(SPTObject object, SPTPosition position) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<SPTPosition>::onWillChange(registry, object.entity);
    
    registry.get<spt::TransformationMatrix>(object.entity).isDirty = true;
    registry.get<SPTPosition>(object.entity) = position;
}

SPTPosition SPTGetPosition(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<SPTPosition>(object.entity);
}

void SPTAddPositionWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentWillChangeListener<SPTPosition>(object, listener, callback);
}

void SPTRemovePositionWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTPosition>(object, listener, callback);
}

void SPTRemovePositionWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<SPTPosition>(object, listener);
}

simd_float3 SPTGetPositionFromSphericalPosition(SPTSphericalPosition sphericalPosition) {
    float lngSin = sinf(sphericalPosition.longitude);
    float lngCos = cosf(sphericalPosition.longitude);
    float latSin = sinf(sphericalPosition.latitude);
    float latCos = cosf(sphericalPosition.latitude);
    return sphericalPosition.center + sphericalPosition.radius * simd_make_float3(lngSin * latSin, latCos, lngCos * latSin);
}


