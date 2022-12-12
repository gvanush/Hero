//
//  AnimatorManager.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 20.07.22.
//

#pragma once

#include "Animator.h"
#include "Base.hpp"

#include <vector>
#include <unordered_map>
#include <span>


namespace spt {

class AnimatorManager {
public:
    
    static AnimatorManager& active();
    
    SPTAnimatorId makeAnimator(const SPTAnimator& animator);
    
    void updateAnimator(SPTAnimatorId animatorId, const SPTAnimator& updated);
    
    void destroyAnimator(SPTAnimatorId id);
    
    const SPTAnimator& getAnimator(SPTAnimatorId id) const;
    
    std::span<const SPTAnimatorId> animatorIds() const;
    
    size_t animatorsCount() const { return _registry.view<SPTAnimator>().size(); }
    
    bool animatorExists(SPTAnimatorId id) const { return _registry.valid(id); }
    
    SPTObserverToken addAnimatorWillChangeObserver(SPTAnimatorId id, SPTAnimatorWillChangeObserver observer, SPTObserverUserInfo userInfo);
    void removeAnimatorWillChangeObserver(SPTAnimatorId id, SPTObserverToken token);
    
    SPTObserverToken addCountWillChangeObserver(SPTAnimatorCountWillChangeObserver observer, SPTObserverUserInfo userInfo);
    void removeCountWillChangeObserver(SPTObserverToken token);
    
    float evaluate(SPTAnimatorId id, const SPTAnimatorEvaluationContext& context);
    
    void resetAnimator(SPTAnimatorId id);
    void resetAllAnimators();
    
    void onObjectPropertyBind(SPTAnimatorId animatorId, SPTObject object, SPTAnimatableObjectProperty property);
    void onObjectPropertyUnbind(SPTAnimatorId animatorId, SPTObject object, SPTAnimatableObjectProperty property);
    
private:
    
    float evaluatePan(const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context);
    float evaluateRandom(SPTAnimatorId id, const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context);
    float evaluateNoise(SPTAnimatorId id, const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context);
    float evaluateOscillator(SPTAnimatorId id, const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context);
    
    void notifyCountListeners(size_t newValue);
    
    bool validateAnimator(const SPTAnimator& updated);
    
    AnimatorManager() = default;
    AnimatorManager(const AnimatorManager&) = delete;
    AnimatorManager(AnimatorManager&&) = delete;
    AnimatorManager& operator=(const AnimatorManager&) = delete;
    AnimatorManager& operator=(AnimatorManager&&) = delete;
    
    AnimatorRegistry _registry;
    
    template <typename O, typename U>
    struct ObserverItem {
        O observer;
        U userInfo;
    };
    
    std::array<ObserverItem<SPTAnimatorCountWillChangeObserver, SPTObserverUserInfo>, kMaxObserverCount> _countObserverItems {};
};

};
