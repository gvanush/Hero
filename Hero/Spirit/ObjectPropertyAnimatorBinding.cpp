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


void SPTObjectPropertyBindAnimator(SPTObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::bindAnimator<SPTObjectPropertyPositionX>(object, animatorBinding);
        }
        case SPTObjectPropertyPositionY: {
            return spt::bindAnimator<SPTObjectPropertyPositionY>(object, animatorBinding);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::bindAnimator<SPTObjectPropertyPositionZ>(object, animatorBinding);
        }
    }
}

void SPTObjectPropertyUpdateAnimatorBinding(SPTObjectProperty property, SPTObject object, SPTAnimatorBinding animatorBinding) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::updateAnimatorBinding<SPTObjectPropertyPositionX>(object, animatorBinding);
        }
        case SPTObjectPropertyPositionY: {
            return spt::updateAnimatorBinding<SPTObjectPropertyPositionY>(object, animatorBinding);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::updateAnimatorBinding<SPTObjectPropertyPositionZ>(object, animatorBinding);
        }
    }
}

void SPTObjectPropertyUnbindAnimator(SPTObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::unbindAnimator<SPTObjectPropertyPositionX>(object);
        }
        case SPTObjectPropertyPositionY: {
            return spt::unbindAnimator<SPTObjectPropertyPositionY>(object);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::unbindAnimator<SPTObjectPropertyPositionZ>(object);
        }
    }
}

SPTAnimatorBinding SPTObjectPropertyGetAnimatorBinding(SPTObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::getAnimatorBinding<SPTObjectPropertyPositionX>(object);
        }
        case SPTObjectPropertyPositionY: {
            return spt::getAnimatorBinding<SPTObjectPropertyPositionY>(object);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::getAnimatorBinding<SPTObjectPropertyPositionZ>(object);
        }
    }
}

const SPTAnimatorBinding* _Nullable SPTObjectPropertyTryGetAnimatorBinding(SPTObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::tryGetAnimatorBinding<SPTObjectPropertyPositionX>(object);
        }
        case SPTObjectPropertyPositionY: {
            return spt::tryGetAnimatorBinding<SPTObjectPropertyPositionY>(object);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::tryGetAnimatorBinding<SPTObjectPropertyPositionZ>(object);
        }
    }
}

bool SPTObjectPropertyIsAnimatorBound(SPTObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::isAnimatorBound<SPTObjectPropertyPositionX>(object);
        }
        case SPTObjectPropertyPositionY: {
            return spt::isAnimatorBound<SPTObjectPropertyPositionY>(object);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::isAnimatorBound<SPTObjectPropertyPositionZ>(object);
        }
    }
}

SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillChangeObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillChangeObserver observer, SPTComponentObserverUserInfo userInfo) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::addAnimatorBindingWillChangeObserver<SPTObjectPropertyPositionX>(object, observer, userInfo);
        }
        case SPTObjectPropertyPositionY: {
            return spt::addAnimatorBindingWillChangeObserver<SPTObjectPropertyPositionY>(object, observer, userInfo);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::addAnimatorBindingWillChangeObserver<SPTObjectPropertyPositionZ>(object, observer, userInfo);
        }
    }
}

void SPTObjectPropertyRemoveAnimatorBindingWillChangeObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTObjectPropertyPositionX>(object, token);
        }
        case SPTObjectPropertyPositionY: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTObjectPropertyPositionY>(object, token);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTObjectPropertyPositionZ>(object, token);
        }
    }
}

SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillEmergeObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTObjectPropertyPositionX>(object, observer, userInfo);
        }
        case SPTObjectPropertyPositionY: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTObjectPropertyPositionY>(object, observer, userInfo);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTObjectPropertyPositionZ>(object, observer, userInfo);
        }
    }
}

void SPTObjectPropertyRemoveAnimatorBindingWillEmergeObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTObjectPropertyPositionX>(object, token);
        }
        case SPTObjectPropertyPositionY: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTObjectPropertyPositionY>(object, token);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTObjectPropertyPositionZ>(object, token);
        }
    }
}

SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillPerishObserver(SPTObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTComponentObserverUserInfo userInfo) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::addAnimatorBindingWillPerishObserver<SPTObjectPropertyPositionX>(object, observer, userInfo);
        }
        case SPTObjectPropertyPositionY: {
            return spt::addAnimatorBindingWillPerishObserver<SPTObjectPropertyPositionY>(object, observer, userInfo);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::addAnimatorBindingWillPerishObserver<SPTObjectPropertyPositionZ>(object, observer, userInfo);
        }
    }
}

void SPTObjectPropertyRemoveAnimatorBindingWillPerishObserver(SPTObjectProperty property, SPTObject object, SPTObserverToken token) {
    switch (property) {
        case SPTObjectPropertyPositionX: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTObjectPropertyPositionX>(object, token);
        }
        case SPTObjectPropertyPositionY: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTObjectPropertyPositionY>(object, token);
        }
        case SPTObjectPropertyPositionZ: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTObjectPropertyPositionZ>(object, token);
        }
    }
}
