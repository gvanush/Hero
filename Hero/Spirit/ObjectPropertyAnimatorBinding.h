//
//  ObjectProperty.h
//  Hero
//
//  Created by Vanush Grigoryan on 15.08.22.
//

#pragma once

#include "Base.h"
#include "AnimatableObjectProperty.h"
#include "AnimatorBinding.h"


SPT_EXTERN_C_BEGIN

void SPTObjectPropertyBindAnimator(SPTAnimatableObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTObjectPropertyUpdateAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTObjectPropertyUnbindAnimator(SPTAnimatableObjectProperty property, SPTObject object);

void SPTObjectPropertyUnbindAnimatorIfBound(SPTAnimatableObjectProperty property, SPTObject object);

SPTAnimatorBinding SPTObjectPropertyGetAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object);

const SPTAnimatorBinding* _Nullable SPTObjectPropertyTryGetAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object);

bool SPTObjectPropertyIsAnimatorBound(SPTAnimatableObjectProperty property, SPTObject object);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillChangeObserver) (SPTAnimatorBinding, SPTObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingWillChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingDidChangeObserver) (SPTAnimatorBinding, SPTObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingDidChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingDidChangeObserver observer, SPTObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingDidChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingDidEmergeObserver) (SPTAnimatorBinding, SPTObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingDidEmergeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingDidEmergeObserver observer, SPTObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingDidEmergeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillPerishObserver) (SPTObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillPerishObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingWillPerishObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
