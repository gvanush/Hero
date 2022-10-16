//
//  ObjectProperty.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.08.22.
//

#include "ObjectPropertyAnimatorBinding.h"
#include "ObjectPropertyAnimatorBinding.h"
#include "Scene.hpp"
#include "ObjectPropertyAnimatorBindingUtil.hpp"
#include "ObjectPropertyAnimatorBindingObserverUtil.hpp"


void SPTObjectPropertyBindAnimator(SPTAnimatableObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyPositionX>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyPositionY>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyPositionZ>(object, animatorBinding);
        }
    }
}

void SPTObjectPropertyUpdateAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyPositionX>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyPositionY>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyPositionZ>(object, animatorBinding);
        }
    }
}

void SPTObjectPropertyUnbindAnimator(SPTAnimatableObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyPositionX>(object);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyPositionY>(object);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyPositionZ>(object);
        }
    }
}

SPTAnimatorBinding SPTObjectPropertyGetAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyPositionX>(object);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyPositionY>(object);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyPositionZ>(object);
        }
    }
}

const SPTAnimatorBinding* _Nullable SPTObjectPropertyTryGetAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyPositionX>(object);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyPositionY>(object);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyPositionZ>(object);
        }
    }
}

bool SPTObjectPropertyIsAnimatorBound(SPTAnimatableObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyPositionX>(object);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyPositionY>(object);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyPositionZ>(object);
        }
    }
}

SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyPositionX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyPositionY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyPositionZ>(object, observer, userInfo);
        }
    }
}

void SPTObjectPropertyRemoveAnimatorBindingWillChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyPositionX>(object, token);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyPositionY>(object, token);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyPositionZ>(object, token);
        }
    }
}

SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillEmergeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillEmergeObserver observer, SPTObserverUserInfo userInfo) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyPositionX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyPositionY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyPositionZ>(object, observer, userInfo);
        }
    }
}

void SPTObjectPropertyRemoveAnimatorBindingWillEmergeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyPositionX>(object, token);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyPositionY>(object, token);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyPositionZ>(object, token);
        }
    }
}

SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillPerishObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyPositionX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyPositionY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyPositionZ>(object, observer, userInfo);
        }
    }
}

void SPTObjectPropertyRemoveAnimatorBindingWillPerishObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token) {
    switch (property) {
        case SPTAnimatableObjectPropertyPositionX: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyPositionX>(object, token);
        }
        case SPTAnimatableObjectPropertyPositionY: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyPositionY>(object, token);
        }
        case SPTAnimatableObjectPropertyPositionZ: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyPositionZ>(object, token);
        }
    }
}
