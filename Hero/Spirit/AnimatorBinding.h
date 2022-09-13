//
//  AnimatorBinding.h
//  Hero
//
//  Created by Vanush Grigoryan on 10.08.22.
//

#pragma once

#include "Base.h"
#include "Animator.h"


SPT_EXTERN_C_BEGIN

typedef struct {
    SPTAnimatorId animatorId;
    float valueAt0;
    float valueAt1;
} SPTAnimatorBinding;

bool SPTAnimatorBindingEqual(SPTAnimatorBinding lhs, SPTAnimatorBinding rhs);

float SPTAnimatorBindingEvaluate(SPTAnimatorBinding binding, float animatorValue);

SPT_EXTERN_C_END
