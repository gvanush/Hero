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

#define kSPTAnimatorNameMaxLength 16

typedef struct {
    simd_float2 panLocation;
    double time;
    long samplingRate;
} SPTAnimatorEvaluationContext;

typedef struct {
    SPTAnimatorSource source;
    char _name[kSPTAnimatorNameMaxLength + 1];
} SPTAnimator;

typedef struct {
    const SPTAnimatorId* _Nullable _data;
    size_t startIndex;
    size_t endIndex;
} SPTAnimatorIdSlice;

bool SPTAnimatorEqual(SPTAnimator lhs, SPTAnimator rhs);

SPTAnimatorId SPTAnimatorMake(SPTAnimator animator);

void SPTAnimatorUpdate(SPTAnimatorId id, SPTAnimator updated);

void SPTAnimatorDestroy(SPTAnimatorId id);

SPTAnimator SPTAnimatorGet(SPTAnimatorId id);

SPTAnimatorIdSlice SPTAnimatorGetAllIds();

bool SPTAnimatorExists(SPTAnimatorId id);

typedef void (* _Nonnull SPTAnimatorWillChangeObserver) (SPTAnimator, SPTObserverUserInfo);
SPTObserverToken SPTAnimatorAddWillChangeObserver(SPTAnimatorId id, SPTAnimatorWillChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTAnimatorRemoveWillChangeObserver(SPTAnimatorId id, SPTObserverToken token);

size_t SPTAnimatorGetCount();

typedef void (* _Nonnull SPTAnimatorCountWillChangeObserver) (size_t, SPTObserverUserInfo);
SPTObserverToken SPTAnimatorAddCountWillChangeObserver(SPTAnimatorCountWillChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTAnimatorRemoveCountWillChangeObserver(SPTObserverToken token);

float SPTAnimatorEvaluateValue(SPTAnimatorId id, SPTAnimatorEvaluationContext context);

void SPTAnimatorReset(SPTAnimatorId id);

void SPTAnimatorResetAll();

SPT_EXTERN_C_END
