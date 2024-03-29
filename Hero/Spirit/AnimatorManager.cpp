//
//  AnimatorManager.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 20.07.22.
//

#include "Base.hpp"
#include "AnimatorManager.hpp"
#include "ComponentObserverUtil.hpp"
#include "ObjectPropertyAnimatorBinding.h"
#include "Easing.h"

#include <algorithm>
#include <random>
#include <vector>


namespace spt {

namespace {

std::uniform_real_distribution<float> uniformDistribution0_1;
std::uniform_real_distribution<float> uniformDistribution1_1 {-1.f, 1.f};

struct AnimatorBindingMetadata {
    
    std::vector<SPTObjectAnimatorBindingMetadataItem> objectBindingMetadata;
    
};

struct RandomAnimatorState {
    
    void reset(uint32_t seed) {
        randomEngine.seed(seed);
        lastValueGenerationTime = 0.0;
        period = 0.0;
    }
    
    std::minstd_rand randomEngine;
    double lastValueGenerationTime;
    double period;
    float lastValue;
};

struct ValueNoiseAnimatorState {
    
    void reset(uint32_t seed) {
        randomEngine.seed(seed);
        startTime = 0.0;
        interpolationDuration = 0.0;
        startValue = 0.f;
        targetValue = uniformDistribution0_1(randomEngine);
    }
    
    std::minstd_rand randomEngine;
    double startTime;
    double interpolationDuration;
    float startValue;
    float targetValue;
};

struct PerlinNoiseAnimatorState {
    
    void reset(uint32_t seed) {
        randomEngine.seed(seed);
        startTime = 0.0;
        interpolationDuration = 0.0;
        startGradient = 0.f;
        targetGradient = uniformDistribution1_1(randomEngine);
    }
    
    std::minstd_rand randomEngine;
    double startTime;
    double interpolationDuration;
    float startGradient;
    float targetGradient;
};

struct OscillatorAnimatorState {
    
    void reset() {
        startTime = 0.0;
        interpolationDuration = 0.0;
        targetValue = 1.f;
    }
    
    double startTime;
    double interpolationDuration;
    float targetValue;
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
            _registry.emplace<RandomAnimatorState>(id);
            break;
        }
        case SPTAnimatorSourceTypeNoise: {
            switch (animator.source.noise.type) {
                case SPTNoiseTypeValue:
                    _registry.emplace<ValueNoiseAnimatorState>(id);
                    break;
                case SPTNoiseTypePerlin:
                    _registry.emplace<PerlinNoiseAnimatorState>(id);
                    break;
            }
            
            break;
        }
        case SPTAnimatorSourceTypeOscillator: {
            _registry.emplace<OscillatorAnimatorState>(id);
            break;
        }
    }
    
    return id;
}

void AnimatorManager::updateAnimator(SPTAnimatorId id, const SPTAnimator& updated) {
    assert(validateAnimator(updated));
    
    spt::notifyComponentWillChangeObservers(_registry, id, updated);
    spt::notifyComponentDidChangeObservers(_registry, id, spt::update(_registry, id, updated));

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
        case SPTAnimatorSourceTypeNoise: {
            return animator.source.noise.frequency >= 0.f;
        }
        case SPTAnimatorSourceTypeOscillator: {
            return animator.source.oscillator.frequency >= 0.f;
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
        case SPTAnimatorSourceTypeNoise: {
            switch (animator.source.noise.type) {
                case SPTNoiseTypeValue:
                    return evaluateValueNoise(id, animator, context);
                case SPTNoiseTypePerlin:
                    return evaluatePerlinNoise(id, animator, context);
            }
        }
        case SPTAnimatorSourceTypeOscillator: {
            return evaluateOscillator(id, animator, context);
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
    while(context.time - state.lastValueGenerationTime >= state.period) {
        state.lastValue = uniformDistribution0_1(state.randomEngine);
        state.lastValueGenerationTime += state.period;
        state.period = 1.f / std::min(animator.source.random.frequency, static_cast<float>(context.samplingRate));
    }
    return state.lastValue;
}

float AnimatorManager::evaluateValueNoise(SPTAnimatorId id, const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context) {
    
    auto& state = _registry.get<ValueNoiseAnimatorState>(id);
    while(context.time - state.startTime >= state.interpolationDuration) {
        state.startValue = state.targetValue;
        state.targetValue = uniformDistribution0_1(state.randomEngine);
        state.startTime += state.interpolationDuration;
        state.interpolationDuration = 1.f / std::min(animator.source.noise.frequency, static_cast<float>(context.samplingRate));
    }
    const auto t = SPTEasingEvaluate(animator.source.noise.interpolation, static_cast<float>((context.time - state.startTime) / state.interpolationDuration));
    return simd_mix(state.startValue, state.targetValue, t);
}

float AnimatorManager::evaluatePerlinNoise(SPTAnimatorId id, const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context) {
    
    auto& state = _registry.get<PerlinNoiseAnimatorState>(id);
    while(context.time - state.startTime >= state.interpolationDuration) {
        state.startGradient = state.targetGradient;
        state.targetGradient = uniformDistribution1_1(state.randomEngine);
        state.startTime += state.interpolationDuration;
        state.interpolationDuration = 1.f / std::min(animator.source.noise.frequency, static_cast<float>(context.samplingRate));
    }
    const auto t = static_cast<float>((context.time - state.startTime) / state.interpolationDuration);
    // The interpolation result is in [-0.5, 0.5] range, therefore bringing to [0, 1] range
    return 0.5f + simd_mix(state.startGradient * t, state.targetGradient * (t - 1.f), SPTEasingEvaluate(animator.source.noise.interpolation, t));
}

float AnimatorManager::evaluateOscillator(SPTAnimatorId id, const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context) {
    
    auto& state = _registry.get<OscillatorAnimatorState>(id);
    while(context.time - state.startTime >= state.interpolationDuration) {
        state.targetValue = 1.f - state.targetValue;
        state.startTime += state.interpolationDuration;
        state.interpolationDuration = 1.f / std::min(animator.source.oscillator.frequency, static_cast<float>(context.samplingRate));
    }
    const auto t = SPTEasingEvaluate(animator.source.oscillator.interpolation, static_cast<float>((context.time - state.startTime) / state.interpolationDuration));
    return simd_mix(1.f - state.targetValue, state.targetValue, t);
    
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
        case SPTAnimatorSourceTypeNoise: {
            switch (animator.source.noise.type) {
                case SPTNoiseTypeValue:
                    _registry.get<ValueNoiseAnimatorState>(id).reset(animator.source.noise.seed);
                    break;
                case SPTNoiseTypePerlin:
                    _registry.get<PerlinNoiseAnimatorState>(id).reset(animator.source.noise.seed);
                    break;
            }
            break;
        }
        case SPTAnimatorSourceTypeOscillator: {
            _registry.get<OscillatorAnimatorState>(id).reset();
            break;
        }
    }
}

void AnimatorManager::resetAllAnimators() {
    _registry.view<SPTAnimator, RandomAnimatorState>().each([](auto entity, const auto& animator, auto& state) {
        assert(animator.source.type == SPTAnimatorSourceTypeRandom);
        state.reset(animator.source.random.seed);
    });
    
    _registry.view<SPTAnimator, ValueNoiseAnimatorState>().each([](auto entity, const auto& animator, auto& state) {
        assert(animator.source.type == SPTAnimatorSourceTypeNoise && animator.source.noise.type == SPTNoiseTypeValue);
        state.reset(animator.source.noise.seed);
    });
    
    _registry.view<SPTAnimator, PerlinNoiseAnimatorState>().each([](auto entity, const auto& animator, auto& state) {
        assert(animator.source.type == SPTAnimatorSourceTypeNoise && animator.source.noise.type == SPTNoiseTypePerlin);
        state.reset(animator.source.noise.seed);
    });
    
    _registry.view<SPTAnimator, OscillatorAnimatorState>().each([](auto entity, const auto& animator, auto& state) {
        assert(animator.source.type == SPTAnimatorSourceTypeOscillator);
        state.reset();
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
