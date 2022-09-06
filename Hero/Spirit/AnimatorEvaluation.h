//
//  AnimatorEvaluation.h
//  Hero
//
//  Created by Vanush Grigoryan on 04.09.22.
//

#pragma once

#include "Base.h"
#include "Animator.h"


SPT_EXTERN_C_BEGIN

typedef simd_float2 (* _Nonnull SPTPanLocationGetter) ();

typedef struct {
    SPTPanLocationGetter getPanLocation;
} SPTAnimatorEvaluationContext;

float SPTAnimatorGetValue(SPTAnimator animator, float loc);

void SPTAnimatorEvaluate(SPTAnimatorId animatorId, const SPTAnimatorEvaluationContext* _Nonnull context);

void SPTAnimatorEvaluateAll(const SPTAnimatorEvaluationContext* _Nonnull context);

SPT_EXTERN_C_END
