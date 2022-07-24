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
    auto& registry = spt::Scene::getRegistry(object);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTScale>(object.entity, scale);
}

void SPTScaleUpdate(SPTObject object, SPTScale newScale) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::ComponentUpdateNotifier<SPTScale>::onWillChange(registry, object.entity, newScale);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTScale>(object.entity) = newScale;
}

SPTScale SPTScaleGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTScale>(object.entity);
}

void SPTScaleAddWillChangeListener(SPTObject object, SPTListener listener, SPTScaleWillChangeCallback callback) {
    spt::addComponentWillChangeListener<SPTScale>(object, listener, callback);
}

void SPTScaleRemoveWillChangeListenerCallback(SPTObject object, SPTListener listener, SPTScaleWillChangeCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTScale>(object, listener, callback);
}

void SPTScaleRemoveWillChangeListener(SPTObject object, SPTListener listener) {
    spt::removeComponentWillChangeListener<SPTScale>(object, listener);
}
