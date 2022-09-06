//
//  AnimatorEvaluation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 04.09.22.
//

#include "AnimatorEvaluation.h"
#include "AnimatorManager.hpp"

// TODO
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


void SPTAnimatorEvaluate(SPTAnimatorId animatorId, const SPTAnimatorEvaluationContext* _Nonnull context) {
    spt::AnimatorManager::active().evaluate(animatorId, context);
}

void SPTAnimatorEvaluateAll(const SPTAnimatorEvaluationContext* _Nonnull context) {
    spt::AnimatorManager::active().evaluateAll(context);
}
