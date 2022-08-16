//
//  AnimatorBinding.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 10.08.22.
//

#include "AnimatorBinding.h"
#include "AnimatorBinding.hpp"
#include "Scene.hpp"
#include "ComponentObserverUtil.hpp"


bool SPTAnimatorBindingEqual(SPTAnimatorBinding lhs, SPTAnimatorBinding rhs) {
    return lhs.animatorId == rhs.animatorId && lhs.valueAt0 == rhs.valueAt0 && lhs.valueAt1 == rhs.valueAt1;
}

void SPTAnimatorBindingMake(SPTObject object, SPTAnimatorBinding animatorBinding) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillEmergeObservers(registry, object.entity, animatorBinding);
    registry.emplace<SPTAnimatorBinding>(object.entity, animatorBinding);
}

void SPTAnimatorBindingUpdate(SPTObject object, SPTAnimatorBinding animatorBinding) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, animatorBinding);
    registry.get<SPTAnimatorBinding>(object.entity) = animatorBinding;
}

void SPTAnimatorBindingDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillPerishObservers<SPTAnimatorBinding>(registry, object.entity);
    registry.erase<SPTAnimatorBinding>(object.entity);
}

SPTAnimatorBinding SPTAnimatorBindingGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTAnimatorBinding>(object.entity);
}

const SPTAnimatorBinding* _Nullable SPTAnimatorBindingTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTAnimatorBinding>(object.entity);
}

bool SPTAnimatorBindingExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTAnimatorBinding>(object.entity);
}

SPTObserverToken SPTAnimatorBindingAddWillChangeObserver(SPTObject object, SPTAnimatorBindingWillChangeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTAnimatorBinding>(object, observer, userInfo);
}

void SPTAnimatorBindingRemoveWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTAnimatorBinding>(object, token);
}

SPTObserverToken SPTAnimatorBindingAddWillEmergeObserver(SPTObject object, SPTAnimatorBindingWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillEmergeObserver<SPTAnimatorBinding>(object, observer, userInfo);
}

void SPTAnimatorBindingRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillEmergeObserver<SPTAnimatorBinding>(object, token);
}

SPTObserverToken SPTAnimatorBindingAddWillPerishObserver(SPTObject object, SPTAnimatorBindingWillPerishObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTAnimatorBinding>(object, observer, userInfo);
}

void SPTAnimatorBindingRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTAnimatorBinding>(object, token);
}
