//
//  Orientation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Orientation.h"
#include "Scene.hpp"
#include "Transformation.hpp"
#include "ComponentListenerUtil.hpp"
#include "ComponentUpdateNotifier.hpp"

void SPTMakeOrientation(SPTObject object, SPTOrientation orientation) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.emplace_or_replace<spt::TransformationMatrix>(object.entity, matrix_identity_float4x4, true);
    registry.emplace<SPTOrientation>(object.entity, orientation);
}

void SPTUpdateOrientation(SPTObject object, SPTOrientation orientation) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<SPTOrientation>::onWillChange(registry, object.entity);
    
    registry.get<spt::TransformationMatrix>(object.entity).isDirty = true;
    registry.get<SPTOrientation>(object.entity) = orientation;
}

SPTOrientation SPTGetOrientation(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<SPTOrientation>(object.entity);
}

void SPTAddOrientationWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentWillChangeListener<SPTEulerOrientation>(object, listener, callback);
}

void SPTRemoveOrientationWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTEulerOrientation>(object, listener, callback);
}

void SPTRemoveOrientationWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<SPTEulerOrientation>(object, listener);
}
