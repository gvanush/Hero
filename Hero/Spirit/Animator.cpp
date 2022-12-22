//
//  Animator.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.07.22.
//

#include "AnimatorManager.hpp"


bool SPTAnimatorEqual(SPTAnimator lhs, SPTAnimator rhs) {
    return lhs.source.type == rhs.source.type && SPTAnimatorSourceEqual(lhs.source, rhs.source) && strcmp(lhs._name, rhs._name) == 0;
}

SPTAnimatorId SPTAnimatorMake(SPTAnimator object) {
    return spt::AnimatorManager::active().makeAnimator(object);
}

void SPTAnimatorUpdate(SPTAnimatorId id, SPTAnimator updated) {
    spt::AnimatorManager::active().updateAnimator(id, updated);
}

void SPTAnimatorDestroy(SPTAnimatorId id) {
    spt::AnimatorManager::active().destroyAnimator(id);
}

SPTAnimator SPTAnimatorGet(SPTAnimatorId id) {
    return spt::AnimatorManager::active().getAnimator(id);
}

SPTAnimatorIdSlice SPTAnimatorGetAllIds() {
    const auto& span = spt::AnimatorManager::active().animatorIds();
    return SPTAnimatorIdSlice{ span.data(), 0, span.size() };
}

bool SPTAnimatorExists(SPTAnimatorId id) {
    return spt::AnimatorManager::active().animatorExists(id);
}

SPTObserverToken SPTAnimatorAddWillChangeObserver(SPTAnimatorId id, SPTAnimatorWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::AnimatorManager::active().addAnimatorWillChangeObserver(id, observer, userInfo);
}

void SPTAnimatorRemoveWillChangeObserver(SPTAnimatorId id, SPTObserverToken token) {
    spt::AnimatorManager::active().removeAnimatorWillChangeObserver(id, token);
}

size_t SPTAnimatorGetCount() {
    return spt::AnimatorManager::active().animatorsCount();
}

SPTObserverToken SPTAnimatorAddCountWillChangeObserver(SPTAnimatorCountWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::AnimatorManager::active().addCountWillChangeObserver(observer, userInfo);
}

void SPTAnimatorRemoveCountWillChangeObserver(SPTObserverToken token) {
    spt::AnimatorManager::active().removeCountWillChangeObserver(token);
}

float SPTAnimatorEvaluateValue(SPTAnimatorId id, SPTAnimatorEvaluationContext context) {
    return spt::AnimatorManager::active().evaluate(id, context);
}

void SPTAnimatorReset(SPTAnimatorId id) {
    spt::AnimatorManager::active().resetAnimator(id);
}

void SPTAnimatorResetAll() {
    spt::AnimatorManager::active().resetAllAnimators();
}
