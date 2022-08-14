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
    spt::notifyWillEmergeComponentObservers(registry, object.entity, scale);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTScale>(object.entity, scale);
}

void SPTScaleUpdate(SPTObject object, SPTScale newScale) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyWillChangeComponentObservers(registry, object.entity, newScale);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTScale>(object.entity) = newScale;
}

void SPTScaleDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyWillPerishComponentObservers<SPTScale>(registry, object.entity);
    registry.erase<SPTScale>(object.entity);
}

SPTScale SPTScaleGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTScale>(object.entity);
}

const SPTScale* _Nullable SPTScaleTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTScale>(object.entity);
}

bool SPTScaleExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTScale>(object.entity);
}

SPTComponentObserverToken SPTScaleAddWillChangeObserver(SPTObject object, SPTScaleWillChangeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveWillChangeObserver(SPTObject object, SPTComponentObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTScale>(object, token);
}

SPTComponentObserverToken SPTScaleAddWillEmergeObserver(SPTObject object, SPTScaleWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillEmergeObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveWillEmergeObserver(SPTObject object, SPTComponentObserverToken token) {
    spt::removeComponentWillEmergeObserver<SPTScale>(object, token);
}

SPTComponentObserverToken SPTScaleAddWillPerishObserver(SPTObject object, SPTScaleWillPerishObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveWillPerishObserver(SPTObject object, SPTComponentObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTScale>(object, token);
}
