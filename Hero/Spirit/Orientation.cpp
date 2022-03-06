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
    spt::ComponentUpdateNotifier<SPTOrientation>::onWillChange(registry, object.entity, newOrientation);
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
    registry.get<SPTOrientation>(object.entity) = newOrientation;
}

SPTOrientation SPTOrientationGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTOrientation>(object.entity);
}

void SPTOrientationAddWillChangeListener(SPTObject object, SPTComponentListener listener, SPTOrientationWillChangeCallback callback) {
    spt::addComponentWillChangeListener<SPTOrientation>(object, listener, callback);
}

void SPTOrientationRemoveWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTOrientationWillChangeCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTOrientation>(object, listener, callback);
}

void SPTOrientationRemoveWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<SPTOrientation>(object, listener);
}
