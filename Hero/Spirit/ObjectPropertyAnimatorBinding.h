//
//  ObjectProperty.h
//  Hero
//
//  Created by Vanush Grigoryan on 15.08.22.
//

#pragma once

#include "Base.h"
#include "ObjectProperty.h"
#include "AnimatorBinding.h"


SPT_EXTERN_C_BEGIN

void SPTObjectPropertyBindAnimator(SPTAnimatableObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTObjectPropertyUpdateAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTObjectPropertyUnbindAnimator(SPTAnimatableObjectProperty property, SPTObject object);

SPTAnimatorBinding SPTObjectPropertyGetAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object);

const SPTAnimatorBinding* _Nullable SPTObjectPropertyTryGetAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object);

bool SPTObjectPropertyIsAnimatorBound(SPTAnimatableObjectProperty property, SPTObject object);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillChangeObserver) (SPTAnimatorBinding, SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillChangeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingWillChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillEmergeObserver) (SPTAnimatorBinding, SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillEmergeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingWillEmergeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillPerishObserver) (SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillPerishObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingWillPerishObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
