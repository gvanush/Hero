//
//  Animator.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.07.22.
//

#include "AnimatorManager.hpp"

const SPTAnimatorId kSPTAnimatorInvalidId = UINT32_MAX;


bool SPTAnimatorEqual(SPTAnimator lhs, SPTAnimator rhs) {
    return lhs.source.type == rhs.source.type && SPTAnimatorSourceEqual(lhs.source, rhs.source) && strcmp(lhs._name, rhs._name) == 0;
}

SPTAnimatorId SPTAnimatorMake(SPTAnimator object) {
    return spt::AnimatorManager::active().makeAnimator(object);
}

void SPTAnimatorUpdate(SPTAnimator updated) {
    spt::AnimatorManager::active().updateAnimator(updated);
}

void SPTAnimatorDestroy(SPTAnimatorId id) {
    spt::AnimatorManager::active().destroyAnimator(id);
}

SPTAnimator SPTAnimatorGet(SPTAnimatorId id) {
    return spt::AnimatorManager::active().getAnimator(id);
}

SPTAnimatorsSlice SPTAnimatorGetAll() {
    const auto& all = spt::AnimatorManager::active().animators();
    return SPTAnimatorsSlice{ all.data(), 0, all.size() };
}

void SPTAnimatorAddWillChangeListener(SPTAnimatorId id, SPTListener listener, SPTAnimatorWillChangeCallback callback) {
    spt::AnimatorManager::active().addWillChangeListener(id, listener, callback);
}

void SPTAnimatorRemoveWillChangeListenerCallback(SPTAnimatorId id, SPTListener listener, SPTAnimatorWillChangeCallback callback) {
    spt::AnimatorManager::active().removeWillChangeListenerCallback(id, listener, callback);
}

void SPTAnimatorRemoveWillChangeListener(SPTAnimatorId id, SPTListener listener) {
    spt::AnimatorManager::active().removeWillChangeListener(id, listener);
}

void SPTAnimatorAddCountWillChangeListener(SPTListener listener, SPTCountWillChangeCallback callback) {
    spt::AnimatorManager::active().addCountWillChangeListener(listener, callback);
}

void SPTAnimatorRemoveCountWillChangeListenerCallback(SPTListener listener, SPTCountWillChangeCallback callback) {
    spt::AnimatorManager::active().removeCountWillChangeListenerCallback(listener, callback);
}

void SPTAnimatorRemoveCountWillChangeListener(SPTListener listener) {
    spt::AnimatorManager::active().removeCountWillChangeListener(listener);
}
