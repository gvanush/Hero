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

void SPTAnimatorBindingMake(SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTAnimatorBindingUpdate(SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTAnimatorBindingDestroy(SPTObject object);

SPTAnimatorBinding SPTAnimatorBindingGet(SPTObject object);

const SPTAnimatorBinding* _Nullable SPTAnimatorBindingTryGet(SPTObject object);

bool SPTAnimatorBindingExists(SPTObject object);

typedef void (* _Nonnull SPTAnimatorBindingWillChangeObserver) (SPTAnimatorBinding, SPTComponentObserverUserInfo);
SPTObserverToken SPTAnimatorBindingAddWillChangeObserver(SPTObject object, SPTAnimatorBindingWillChangeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTAnimatorBindingRemoveWillChangeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTAnimatorBindingWillEmergeObserver) (SPTAnimatorBinding, SPTComponentObserverUserInfo);
SPTObserverToken SPTAnimatorBindingAddWillEmergeObserver(SPTObject object, SPTAnimatorBindingWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTAnimatorBindingRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTAnimatorBindingWillPerishObserver) (SPTComponentObserverUserInfo);
SPTObserverToken SPTAnimatorBindingAddWillPerishObserver(SPTObject object, SPTAnimatorBindingWillPerishObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTAnimatorBindingRemoveWillPerishObserver(SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
