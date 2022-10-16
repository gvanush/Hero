//
//  Scale.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Scale.h"
#include "Scale.hpp"
#include "ComponentObserverUtil.hpp"
#include "Base.hpp"

namespace spt::Scale {

simd_float3 getXYZ(const spt::Registry& registry, SPTEntity entity) {
    if(const auto scale = registry.try_get<SPTScale>(entity); scale) {
        return scale->xyz;
    }
    return {1.f, 1.f, 1.f};
}

}


bool SPTScaleEqual(SPTScale lhs, SPTScale rhs) {
    return simd_equal(lhs.xyz, rhs.xyz);
}

void SPTScaleMake(SPTObject object, SPTScale scale) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillEmergeObservers(registry, object.entity, scale);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTScale>(object.entity, scale);
}

void SPTScaleUpdate(SPTObject object, SPTScale newScale) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, newScale);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTScale>(object.entity) = newScale;
}

void SPTScaleDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillPerishObservers<SPTScale>(registry, object.entity);
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

SPTObserverToken SPTScaleAddWillChangeObserver(SPTObject object, SPTScaleWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTScale>(object, token);
}

SPTObserverToken SPTScaleAddWillEmergeObserver(SPTObject object, SPTScaleWillEmergeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillEmergeObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillEmergeObserver<SPTScale>(object, token);
}

SPTObserverToken SPTScaleAddWillPerishObserver(SPTObject object, SPTScaleWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTScale>(object, token);
}
