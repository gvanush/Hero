//
//  Scale.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Scale.h"
#include "Scale.hpp"
#include "ComponentListenerUtil.hpp"
#include "ComponentUpdateNotifier.hpp"
#include "Base.hpp"


bool SPTScaleEqual(SPTScale lhs, SPTScale rhs) {
    return simd_equal(lhs.xyz, rhs.xyz);
}

void SPTScaleMake(SPTObject object, SPTScale scale) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTScale>(object.entity, scale);
}

void SPTScaleUpdate(SPTObject object, SPTScale newScale) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<SPTScale>::onWillChange(registry, object.entity, newScale);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTScale>(object.entity) = newScale;
}

SPTScale SPTScaleGet(SPTObject object) {
    return static_cast<spt::Scene*>(object.sceneHandle)->registry.get<SPTScale>(object.entity);
}

void SPTScaleAddWillChangeListener(SPTObject object, SPTComponentListener listener, SPTScaleWillChangeCallback callback) {
    spt::addComponentWillChangeListener<SPTScale>(object, listener, callback);
}

void SPTScaleRemoveWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTScaleWillChangeCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTScale>(object, listener, callback);
}

void SPTScaleRemoveWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<SPTScale>(object, listener);
}
