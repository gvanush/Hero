//
//  AnimatorBinding.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 10.08.22.
//

#include "AnimatorBinding.h"
#include "AnimatorBinding.hpp"


bool SPTAnimatorBindingEqual(SPTAnimatorBinding lhs, SPTAnimatorBinding rhs) {
    return lhs.animatorId == rhs.animatorId && lhs.valueAt0 == rhs.valueAt0 && lhs.valueAt1 == rhs.valueAt1;
}

float SPTAnimatorBindingEvaluate(SPTAnimatorBinding binding, float animatorValue) {
    return spt::evaluateAnimatorBinding(binding, animatorValue);
}
