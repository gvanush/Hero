//
//  Animator.h
//  Hero
//
//  Created by Vanush Grigoryan on 18.07.22.
//

#pragma once

#include "Base.h"
#include "AnimatorSource.h"

#include <simd/simd.h>
#include <limits.h>

SPT_EXTERN_C_BEGIN

extern const SPTAnimatorId kSPTAnimatorInvalidId;

#define kSPTAnimatorNameMaxLength 16

typedef struct {
    simd_float2 panLocation;
} SPTAnimatorEvaluationContext;

typedef struct {
    SPTAnimatorId id;
    SPTAnimatorSource source;
    char _name[kSPTAnimatorNameMaxLength + 1];
} SPTAnimator;

typedef struct {
    const SPTAnimator* _Nullable _data;
    size_t startIndex;
    size_t endIndex;
} SPTAnimatorsSlice;

bool SPTAnimatorEqual(SPTAnimator lhs, SPTAnimator rhs);

SPTAnimatorId SPTAnimatorMake(SPTAnimator animator);

void SPTAnimatorUpdate(SPTAnimator updated);

void SPTAnimatorDestroy(SPTAnimatorId id);

SPTAnimator SPTAnimatorGet(SPTAnimatorId id);

SPTAnimatorsSlice SPTAnimatorGetAll();

typedef void (* _Nonnull SPTAnimatorWillChangeCallback) (SPTListener, SPTAnimator);

void SPTAnimatorAddWillChangeListener(SPTAnimatorId id, SPTListener listener, SPTAnimatorWillChangeCallback callback);
void SPTAnimatorRemoveWillChangeListenerCallback(SPTAnimatorId id, SPTListener listener, SPTAnimatorWillChangeCallback callback);
void SPTAnimatorRemoveWillChangeListener(SPTAnimatorId id, SPTListener listener);

void SPTAnimatorAddCountWillChangeListener(SPTListener listener, SPTCountWillChangeCallback callback);
void SPTAnimatorRemoveCountWillChangeListenerCallback(SPTListener listener, SPTCountWillChangeCallback callback);
void SPTAnimatorRemoveCountWillChangeListener(SPTListener listener);

float SPTAnimatorEvaluateValue(SPTAnimator animator, SPTAnimatorEvaluationContext context);

SPT_EXTERN_C_END
