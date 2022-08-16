//
//  Orientation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#include "Orientation.h"
#include "Scene.hpp"
#include "Transformation.hpp"
#include "ComponentObserverUtil.hpp"


bool SPTEulerOrientationEqual(SPTEulerOrientation lhs, SPTEulerOrientation rhs) {
    return simd_equal(lhs.rotation, rhs.rotation) && lhs.order == rhs.order;
}

bool SPTLookAtOrientationEqual(SPTLookAtOrientation lhs, SPTLookAtOrientation rhs) {
    return simd_equal(lhs.target, rhs.target) &&
    simd_equal(lhs.up, rhs.up) &&
    lhs.axis == rhs.axis &&
    lhs.positive == rhs.positive;
}

bool SPTOrientationEqual(SPTOrientation lhs, SPTOrientation rhs) {
    if(lhs.variantTag != rhs.variantTag) {
        return false;
    }
    
    switch (lhs.variantTag) {
        case SPTOrientationVariantTagEuler:
            return SPTEulerOrientationEqual(lhs.euler, rhs.euler);
        case SPTOrientationVariantTagLookAt:
            return SPTLookAtOrientationEqual(lhs.lookAt, rhs.lookAt);
    }
}



void SPTOrientationMake(SPTObject object, SPTOrientation orientation) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillEmergeObservers(registry, object.entity, orientation);
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.emplace<SPTOrientation>(object.entity, orientation);
}

void SPTOrientationMakeEuler(SPTObject object, SPTEulerOrientation euler) {
    SPTOrientationMake(object, {SPTOrientationVariantTagEuler, {.euler = euler}});
}

void SPTOrientationMakeLookAt(SPTObject object, SPTLookAtOrientation lookAt) {
    SPTOrientationMake(object, {SPTOrientationVariantTagLookAt, {.lookAt = lookAt}});
}

void SPTOrientationUpdate(SPTObject object, SPTOrientation newOrientation) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, newOrientation);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTOrientation>(object.entity) = newOrientation;
}

void SPTOrientationDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillPerishObservers<SPTOrientation>(registry, object.entity);
    registry.erase<SPTOrientation>(object.entity);
}

const SPTOrientation* _Nullable SPTOrientationTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTOrientation>(object.entity);
}

SPTOrientation SPTOrientationGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTOrientation>(object.entity);
}

bool SPTOrientationExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTOrientation>(object.entity);
}

SPTObserverToken SPTOrientationAddWillChangeObserver(SPTObject object, SPTOrientationWillChangeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTOrientation>(object, token);
}

SPTObserverToken SPTOrientationAddWillEmergeObserver(SPTObject object, SPTOrientationWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillEmergeObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillEmergeObserver<SPTOrientation>(object, token);
}

SPTObserverToken SPTOrientationAddWillPerishObserver(SPTObject object, SPTOrientationWillPerishObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTOrientation>(object, observer, userInfo);
}

void SPTOrientationRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTOrientation>(object, token);
}
