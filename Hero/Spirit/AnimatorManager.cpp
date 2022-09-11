//
//  AnimatorManager.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 20.07.22.
//

#include "AnimatorManager.hpp"

#include <algorithm>

namespace spt {

AnimatorManager& AnimatorManager::active() {
    static AnimatorManager instance;
    return instance;
}



SPTAnimatorId AnimatorManager::makeAnimator(const SPTAnimator& animator) {
    notifyCountListeners(_animators.size() + 1);
    return _animators.emplace_back(animator).id = AnimatorManager::nextId++;
}

void AnimatorManager::updateAnimator(const SPTAnimator& updated) {
    assert(validateAnimator(updated));
    
    auto it = std::find_if(_animators.begin(), _animators.end(), [&updated] (const auto& animator) {
        return animator.id == updated.id;
    });
    if(it == _animators.end()) {
        assert(false);
        return;
    }
    
    notifyListeners(updated);
    
    *it = updated;
}

void AnimatorManager::destroyAnimator(SPTAnimatorId id) {
    // NOTE: Swap and pop is also a possibility for efficient removal
    auto it = std::find_if(_animators.begin(), _animators.end(), [id] (const auto& animator) {
        return animator.id == id;
    });
    if(it == _animators.end()) {
        return;
    }
    notifyCountListeners(_animators.size() - 1);
    _animators.erase(it);
}

const SPTAnimator& AnimatorManager::getAnimator(SPTAnimatorId id) const {
    auto it = std::find_if(_animators.begin(), _animators.end(), [id] (const auto& animator) {
        return animator.id == id;
    });
    if(it == _animators.end()) {
        assert(false);
    }
    return *it;
}

void AnimatorManager::addWillChangeListener(SPTAnimatorId id, SPTListener listener, SPTAnimatorWillChangeCallback callback) {
    _listeners[id].emplace_back(WillChangeListenerItem<SPTAnimator> {listener, callback});
}

void AnimatorManager::removeWillChangeListenerCallback(SPTAnimatorId id, SPTListener listener, SPTAnimatorWillChangeCallback callback) {
    auto it = _listeners.find(id);
    if(it == _listeners.end()) {
        return;
    }
    
    auto& animListeners = it->second;
    auto lit = std::find_if(animListeners.begin(), animListeners.end(), [listener, callback] (const auto& item) {
        return item.listener == listener && item.callback == callback;
    });
    
    if(lit != animListeners.end()) {
        animListeners.erase(lit);
    }
    
    if(animListeners.empty()) {
        _listeners.erase(it);
    }
    
}

void AnimatorManager::removeWillChangeListener(SPTAnimatorId id, SPTListener listener) {
    auto it = _listeners.find(id);
    if(it == _listeners.end()) {
        return;
    }
    
    auto& animListeners = it->second;
    auto rit = std::remove_if(animListeners.begin(), animListeners.end(), [listener] (const auto& item) {
        return item.listener == listener;
    });
    animListeners.erase(rit, animListeners.end());
    
    if(animListeners.empty()) {
        _listeners.erase(it);
    }
}

void AnimatorManager::addCountWillChangeListener(SPTListener listener, SPTCountWillChangeCallback callback) {
    _countListeners.emplace_back(WillChangeListenerItem<size_t> {listener, callback});
}

void AnimatorManager::removeCountWillChangeListenerCallback(SPTListener listener, SPTCountWillChangeCallback callback) {
    auto it = std::find_if(_countListeners.begin(), _countListeners.end(), [listener, callback] (const auto& item) {
        return item.listener == listener && item.callback == callback;
    });
    if(it == _countListeners.end()) {
        return;
    }
    _countListeners.erase(it);
}

void AnimatorManager::removeCountWillChangeListener(SPTListener listener) {
    _countListeners.erase(std::remove_if(_countListeners.begin(), _countListeners.end(), [listener] (const auto& item) {
        return item.listener == listener;
    }), _countListeners.end());
}

void AnimatorManager::notifyListeners(const SPTAnimator& newValue) {
    auto it = _listeners.find(newValue.id);
    if(it == _listeners.end()) {
        return;
    }
    
    for(const auto& item: it->second) {
        item.callback(item.listener, newValue);
    }
}

void AnimatorManager::notifyCountListeners(size_t newValue) {
    for(const auto& item: _countListeners) {
        item.callback(item.listener, newValue);
    }
}

bool AnimatorManager::validateAnimator(const SPTAnimator& animator) {
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan: {
            return animator.source.pan.bottomLeft.x >= 0.f && animator.source.pan.bottomLeft.x <= animator.source.pan.topRight.x && animator.source.pan.topRight.x <= 1.f && animator.source.pan.bottomLeft.y >= 0.f && animator.source.pan.bottomLeft.y <= animator.source.pan.topRight.y && animator.source.pan.topRight.y <= 1.f;
        }
        case SPTAnimatorSourceTypeFace: {
            return false;
        }
    }
}

float AnimatorManager::evaluate(const SPTAnimator& animator, const SPTAnimatorEvaluationContext& context) {
    switch (animator.source.type) {
        case SPTAnimatorSourceTypePan: {
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
        case SPTAnimatorSourceTypeFace:
            // TODO
            return 0.f;
    }
}

SPTAnimatorId AnimatorManager::nextId = 0;

}
