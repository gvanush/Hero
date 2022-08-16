//
//  ObjectProperty.h
//  Hero
//
//  Created by Vanush Grigoryan on 15.08.22.
//

#pragma once

#include "Base.h"
#include "AnimatorBinding.h"

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTObjectPropertyPositionX,
    SPTObjectPropertyPositionY,
    SPTObjectPropertyPositionZ,
} __attribute__((enum_extensibility(open))) SPTObjectProperty;

void SPTObjectPropertyBindAnimator(SPTObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTObjectPropertyUpdateAnimatorBinding(SPTObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding);

void SPTObjectPropertyUnbindAnimator(SPTObjectProperty property, SPTObject object);

SPTAnimatorBinding SPTObjectPropertyGetAnimatorBinding(SPTObjectProperty property, SPTObject object);

const SPTAnimatorBinding* _Nullable SPTObjectPropertyTryGetAnimatorBinding(SPTObjectProperty property, SPTObject object);

bool SPTObjectPropertyIsAnimatorBound(SPTObjectProperty property, SPTObject object);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillChangeObserver) (SPTAnimatorBinding, SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAnimatorBindingAddWillChangeObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillChangeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyAnimatorBindingRemoveWillChangeObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillEmergeObserver) (SPTAnimatorBinding, SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAnimatorBindingAddWillEmergeObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyAnimatorBindingRemoveWillEmergeObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token);

typedef void (* _Nonnull SPTObjectPropertyAnimatorBindingWillPerishObserver) (SPTComponentObserverUserInfo);
SPTObserverToken SPTObjectPropertyAnimatorBindingAddWillPerishObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTComponentObserverUserInfo userInfo);
void SPTObjectPropertyAnimatorBindingRemoveWillPerishObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token);

SPT_EXTERN_C_END
