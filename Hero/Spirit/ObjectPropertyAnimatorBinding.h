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

void SPTObjectPropertyBindAnimator(SPTObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTObjectPropertyUpdateAnimatorBinding(SPTObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTObjectPropertyUnbindAnimator(SPTObjectProperty property, SPTObject object);

SPTAnimatorBinding SPTObjectPropertyGetAnimatorBinding(SPTObjectProperty property, SPTObject object);

const SPTAnimatorBinding* _Nullable SPTObjectPropertyTryGetAnimatorBinding(SPTObjectProperty property, SPTObject object);

bool SPTObjectPropertyIsAnimatorBound(SPTObjectProperty property, SPTObject object);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillChangeObserver) (SPTAnimatorBinding, SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillChangeObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillChangeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingWillChangeObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillEmergeObserver) (SPTAnimatorBinding, SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillEmergeObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingWillEmergeObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillPerishObserver) (SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillPerishObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyRemoveAnimatorBindingWillPerishObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
