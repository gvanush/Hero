//
//  AnimatorManager.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 20.07.22.
//

#include "AnimatorManager.hpp"
#include "ComponentObserverUtil.hpp"
#include "ObjectPropertyAnimatorBinding.h"

#include <algorithm>
#include <random>
#include <vector>


namespace spt {

namespace {

std::uniform_real_distribution<float> uniformDistribution;

struct AnimatorBindingMetadata {
    
    std::vector<SPTObjectAnimatorBindingMetadataItem> objectBindingMetadata;
    
};

struct RandomAnimatorState {
    
    explicit RandomAnimatorState(uint32_t seed)
    : randomEngine {seed}
    , lastValueGenerationTime {0.0}
    , lastValue {uniformDistribution(randomEngine)} {
    }
    
    void reset(uint32_t seed) {
        randomEngine.seed(seed);
        lastValueGenerationTime = 0.0;
        lastValue = uniformDistribution(randomEngine);
    }
    
    std::minstd_rand randomEngine;
    double lastValueGenerationTime;
    float lastValue;
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
    _registry.emplace<AnimatorBindingMetadata>(id);
    
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
            if(animator.source.random.seed != updated.source.random.seed) {
                _registry.get<RandomAnimatorState>(id).reset(updated.source.random.seed);
            }
            break;
        }
    }
    
    animator = updated;
}

void AnimatorManager::destroyAnimator(SPTAnimatorId animatorId) {
    notifyCountListeners(animatorsCount() - 1);
    
    auto& metadata = _registry.get<AnimatorBindingMetadata>(animatorId);
    for(const auto& item: metadata.objectBindingMetadata) {
        SPTObjectPropertyUnbindAnimator(item.property, item.object);
    }
    
    _registry.destroy(animatorId);
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
            return animator.source.random.frequency >= 0.f;
        }
    }
}

float AnimatorManager::evaluate(SPTAnimatorId id, const SPTAnimatorEvaluationContext& context) {
    
    const auto& animator = _registry.get<SPTAnimator>(id);
    
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan: {
            return evaluatePan(animator, context);
        }
        case SPTAnimatorSourceTypeRandom: {
            return evaluateRandom(id, animator, context);
        }
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

float AnimatorManager::evaluateRandom(SPTAnimatorId id, const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context) {
    
    auto& state = _registry.get<RandomAnimatorState>(id);
    const auto period = 1.f / std::min(animator.source.random.frequency, static_cast<float>(context.samplingRate));
    while((context.time - state.lastValueGenerationTime) >= period) {
        state.lastValue = uniformDistribution(state.randomEngine);
        state.lastValueGenerationTime += period;
    }
    return state.lastValue;
}

void AnimatorManager::resetAnimator(SPTAnimatorId id) {
    const auto& animator = _registry.get<SPTAnimator>(id);
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan: {
            break;
        }
        case SPTAnimatorSourceTypeRandom: {
            _registry.get<RandomAnimatorState>(id).reset(animator.source.random.seed);
            break;
        }
    }
}

void AnimatorManager::resetAllAnimators() {
    _registry.view<SPTAnimator, RandomAnimatorState>().each([](auto entity, const auto& animator, auto& state) {
        assert(animator.source.type == SPTAnimatorSourceTypeRandom);
        state.reset(animator.source.random.seed);
    });
}

void AnimatorManager::onObjectPropertyBind(SPTAnimatorId animatorId, SPTObject object, SPTAnimatableObjectProperty property) {
    auto& metadata = _registry.get<AnimatorBindingMetadata>(animatorId);
    metadata.objectBindingMetadata.push_back({object, property});
}

void AnimatorManager::onObjectPropertyUnbind(SPTAnimatorId animatorId, SPTObject object, SPTAnimatableObjectProperty property) {
    
    auto& metadata = _registry.get<AnimatorBindingMetadata>(animatorId);
    auto it = std::find_if(metadata.objectBindingMetadata.begin(), metadata.objectBindingMetadata.end(), [object, property] (const auto& item) {
        return SPTObjectEqual(item.object, object) && item.property == property;
    });
    
    if(it == metadata.objectBindingMetadata.end()) {
        return;
    }
    
    metadata.objectBindingMetadata.erase(it);
}

}
