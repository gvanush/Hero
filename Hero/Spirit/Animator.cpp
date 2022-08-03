//
//  Animator.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.07.22.
//

#include "AnimatorManager.hpp"

bool SPTAnimatorEqual(SPTAnimator lhs, SPTAnimator rhs) {
    // TODO: @Vanush
//    return lhs.source.type == rhs.source.type && strcmp(lhs._name, rhs._name) == 0;
    return false;
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

float SPTAnimatorGetValue(SPTAnimator animator, float loc) {
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan: {
            switch (animator.source.pan.axis) {
                case SPTPanAnimatorSourceAxisHorizontal: {
                    const auto v = simd_clamp(loc, animator.source.pan.bottomLeft.x, animator.source.pan.topRight.x);
                    return (v - animator.source.pan.bottomLeft.x) / (animator.source.pan.topRight.x - animator.source.pan.bottomLeft.x);
                }
                case SPTPanAnimatorSourceAxisVertical: {
                    const auto v = simd_clamp(loc, animator.source.pan.bottomLeft.y, animator.source.pan.topRight.y);
                    return (v - animator.source.pan.bottomLeft.y) / (animator.source.pan.topRight.y - animator.source.pan.bottomLeft.y);
                }
            }
        }
        case SPTAnimatorSourceTypeFace: {
            return 0.0;
        }
    }
    
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
