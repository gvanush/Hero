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

namespace spt {

class AnimatorManager {
public:
    
    static AnimatorManager& active();
    
    SPTAnimatorId makeAnimator(const SPTAnimator& animator);
    
    void updateAnimator(const SPTAnimator& updated);
    
    void destroyAnimator(SPTAnimatorId id);
    
    const SPTAnimator& getAnimator(SPTAnimatorId id);
    
    const std::vector<SPTAnimator>& animators() const { return _animators; };
    
    void addWillChangeListener(SPTAnimatorId id, SPTListener listener, SPTAnimatorWillChangeCallback callback);
    void removeWillChangeListenerCallback(SPTAnimatorId id, SPTListener listener, SPTAnimatorWillChangeCallback callback);
    void removeWillChangeListener(SPTAnimatorId id, SPTListener listener);
    
    void addCountWillChangeListener(SPTListener listener, SPTCountWillChangeCallback callback);
    void removeCountWillChangeListenerCallback(SPTListener listener, SPTCountWillChangeCallback callback);
    void removeCountWillChangeListener(SPTListener listener);
    
private:
    
    void notifyListeners(const SPTAnimator& newValue);
    void notifyCountListeners(size_t newValue);
    
    AnimatorManager() = default;
    AnimatorManager(const AnimatorManager&) = delete;
    AnimatorManager(AnimatorManager&&) = delete;
    AnimatorManager& operator=(const AnimatorManager&) = delete;
    AnimatorManager& operator=(AnimatorManager&&) = delete;
    
    static SPTAnimatorId nextId;
    
    std::vector<SPTAnimator> _animators;
    std::unordered_map<SPTAnimatorId, std::vector<WillChangeListenerItem<SPTAnimator>>> _listeners;
    std::vector<WillChangeListenerItem<size_t>> _countListeners;
};

};
