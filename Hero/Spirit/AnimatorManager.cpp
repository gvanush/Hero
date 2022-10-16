//
//  AnimatorManager.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 20.07.22.
//

#include "AnimatorManager.hpp"
#include "ComponentObserverUtil.hpp"

#include <algorithm>
#include <random>


namespace spt {

namespace {

std::uniform_real_distribution<float> uniformDistribution;

struct RandomAnimatorState {
    
    explicit RandomAnimatorState(uint32_t seed)
    : randomEngine{seed} {
        
    }
    
    std::minstd_rand randomEngine;
};

}

AnimatorManager& AnimatorManager::active() {
    static AnimatorManager instance;
    return instance;
}

SPTAnimatorId AnimatorManager::makeAnimator(const SPTAnimator& animator) {
    assert(validateAnimator(animator));
    
    notifyCountListeners(animatorsCount() + 1);
    
    auto id = _registry.create();
    _registry.emplace<SPTAnimator>(id, animator);
    
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan:
            break;
        case SPTAnimatorSourceTypeRandom: {
            _registry.emplace<RandomAnimatorState>(id, animator.source.random.seed);
            break;
        }
    }
    
    return id;
}

void AnimatorManager::updateAnimator(SPTAnimatorId id, const SPTAnimator& updated) {
    assert(validateAnimator(updated));
    
    spt::notifyComponentWillChangeObservers(_registry, id, updated);
    
    auto& animator = _registry.get<SPTAnimator>(id);
    
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan:
            break;
        case SPTAnimatorSourceTypeRandom: {
            _registry.get<RandomAnimatorState>(id).randomEngine.seed(updated.source.random.seed);
            break;
        }
    }
    
    animator = updated;
}

void AnimatorManager::destroyAnimator(SPTAnimatorId id) {
    notifyCountListeners(animatorsCount() - 1);
    _registry.destroy(id);
}

const SPTAnimator& AnimatorManager::getAnimator(SPTAnimatorId id) const {
    return _registry.get<SPTAnimator>(id);
}

std::span<const SPTAnimatorId> AnimatorManager::animatorIds() const {
    const auto& view = _registry.view<SPTAnimator>();
    return {view.data(), view.size()};
}

SPTObserverToken AnimatorManager::addAnimatorWillChangeObserver(SPTAnimatorId id, SPTAnimatorWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTAnimator>(observer, userInfo, _registry, id);
}

void AnimatorManager::removeAnimatorWillChangeObserver(SPTAnimatorId id, SPTObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTAnimator>(token, _registry, id);
}

SPTObserverToken AnimatorManager::addCountWillChangeObserver(SPTAnimatorCountWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    
    auto it = std::find_if(_countObserverItems.begin(), _countObserverItems.end(), [](const auto& item) {
        return item.observer == nullptr;
    });
    assert(it != _countObserverItems.end()); // No free slot to register observer
    
    it->observer = observer;
    it->userInfo = userInfo;
    return static_cast<SPTObserverToken>(it - _countObserverItems.begin());
}

void AnimatorManager::removeCountWillChangeObserver(SPTObserverToken token) {
    _countObserverItems[token].observer = nullptr;
}

void AnimatorManager::notifyCountListeners(size_t newCount) {
    for(const auto& item: _countObserverItems) {
        if(item.observer) {
            item.observer(newCount, item.userInfo);
        }
    }
}

bool AnimatorManager::validateAnimator(const SPTAnimator& animator) {
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan: {
            return animator.source.pan.bottomLeft.x >= 0.f && animator.source.pan.bottomLeft.x <= animator.source.pan.topRight.x && animator.source.pan.topRight.x <= 1.f && animator.source.pan.bottomLeft.y >= 0.f && animator.source.pan.bottomLeft.y <= animator.source.pan.topRight.y && animator.source.pan.topRight.y <= 1.f;
        }
        case SPTAnimatorSourceTypeRandom: {
            return true;
        }
    }
}

float AnimatorManager::evaluate(SPTAnimatorId id, const SPTAnimatorEvaluationContext& context) {
    
    const auto& animator = _registry.get<SPTAnimator>(id);
    
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan: {
            return evaluatePan(animator, context);
        }
        case SPTAnimatorSourceTypeRandom:
            return evaluateRandom(id);
    }
}

float AnimatorManager::evaluatePan(const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context) {
    switch (animator.source.pan.axis) {
        case SPTPanAnimatorSourceAxisHorizontal: {
            const auto v = simd_clamp(context.panLocation.x, animator.source.pan.bottomLeft.x, animator.source.pan.topRight.x);
            return (v - animator.source.pan.bottomLeft.x) / (animator.source.pan.topRight.x - animator.source.pan.bottomLeft.x);
        }
        case SPTPanAnimatorSourceAxisVertical: {
            const auto v = simd_clamp(context.panLocation.y, animator.source.pan.bottomLeft.y, animator.source.pan.topRight.y);
            return (v - animator.source.pan.bottomLeft.y) / (animator.source.pan.topRight.y - animator.source.pan.bottomLeft.y);
        }
    }
}

float AnimatorManager::evaluateRandom(SPTAnimatorId id) {
    return uniformDistribution(_registry.get<RandomAnimatorState>(id).randomEngine);
}

void AnimatorManager::resetAnimator(SPTAnimatorId id) {
    const auto& animator = _registry.get<SPTAnimator>(id);
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan: {
            break;
        }
        case SPTAnimatorSourceTypeRandom: {
            _registry.get<RandomAnimatorState>(id).randomEngine.seed(animator.source.random.seed);
            break;
        }
    }
}

void AnimatorManager::resetAllAnimators() {
    _registry.view<SPTAnimator, RandomAnimatorState>().each([](auto entity, const auto& animator, auto& state) {
        assert(animator.source.type == SPTAnimatorSourceTypeRandom);
        state.randomEngine.seed(animator.source.random.seed);
    });
}

}
