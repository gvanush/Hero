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
        switch (scale->model) {
            case SPTScaleModelXYZ:
                return scale->xyz;
            case SPTScaleModelUniform:
                return {scale->uniform, scale->uniform, scale->uniform};
        }
    }
    return {1.f, 1.f, 1.f};
}

}


bool SPTScaleEqual(SPTScale lhs, SPTScale rhs) {
    if(lhs.model != rhs.model) {
        return false;
    }
    
    switch (lhs.model) {
        case SPTScaleModelXYZ:
            return simd_equal(lhs.xyz, rhs.xyz);
        case SPTScaleModelUniform: {
            return lhs.uniform == rhs.uniform;
        }
    }
}

void SPTScaleMake(SPTObject object, SPTScale scale) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTScale>(object.entity, scale);
    spt::notifyComponentDidEmergeObservers(registry, object.entity, scale);
}

void SPTScaleUpdate(SPTObject object, SPTScale newScale) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, newScale);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    spt::notifyComponentDidChangeObservers(registry, object.entity, spt::update(registry, object.entity, newScale));
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

SPTObserverToken SPTScaleAddDidChangeObserver(SPTObject object, SPTScaleDidChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentDidChangeObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveDidChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentDidChangeObserver<SPTScale>(object, token);
}

SPTObserverToken SPTScaleAddDidEmergeObserver(SPTObject object, SPTScaleDidEmergeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentDidEmergeObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveDidEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentDidEmergeObserver<SPTScale>(object, token);
}

SPTObserverToken SPTScaleAddWillPerishObserver(SPTObject object, SPTScaleWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTScale>(object, observer, userInfo);
}

void SPTScaleRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTScale>(object, token);
}
