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


void SPTOrientationMake(SPTObject object, SPTOrientation orientation) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTOrientation>(object.entity, orientation);
}

void SPTOrientationMakeEuler(SPTObject object, SPTEulerOrientation euler) {
    SPTOrientationMake(object, {SPTOrientationVariantTagEuler, {.euler = euler}});
}

void SPTOrientationMakeLookAt(SPTObject object, SPTLookAtOrientation lookAt) {
    SPTOrientationMake(object, {SPTOrientationVariantTagLookAt, {.lookAt = lookAt}});
}

void SPTOrientationUpdate(SPTObject object, SPTOrientation orientation) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<SPTOrientation>::onWillChange(registry, object.entity);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTOrientation>(object.entity) = orientation;
}

SPTOrientation SPTOrientationGet(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<SPTOrientation>(object.entity);
}

void SPTOrientationAddWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentWillChangeListener<SPTOrientation>(object, listener, callback);
}

void SPTOrientationRemoveWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTOrientation>(object, listener, callback);
}

void SPTOrientationRemoveWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<SPTOrientation>(object, listener);
}
