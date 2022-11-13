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
        case SPTAnimatableObjectPropertyHue: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyHue>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::bindAnimator<SPTAnimatableObjectPropertySaturation>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyBrightness>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyRed>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyGreen>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyBlue>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyShininess>(object, animatorBinding);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyHue>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertySaturation>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyBrightness>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyRed>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyGreen>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyBlue>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyShininess>(object, animatorBinding);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyHue>(object);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertySaturation>(object);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyBrightness>(object);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyRed>(object);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyGreen>(object);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyBlue>(object);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyShininess>(object);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyHue>(object);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertySaturation>(object);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyBrightness>(object);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyRed>(object);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyGreen>(object);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyBlue>(object);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyShininess>(object);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyHue>(object);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertySaturation>(object);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyBrightness>(object);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyRed>(object);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyGreen>(object);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyBlue>(object);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyShininess>(object);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyHue>(object);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertySaturation>(object);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyBrightness>(object);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyRed>(object);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyGreen>(object);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyBlue>(object);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyShininess>(object);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyHue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertySaturation>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyBrightness>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyRed>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyGreen>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyBlue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyShininess>(object, observer, userInfo);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyHue>(object, token);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertySaturation>(object, token);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyBrightness>(object, token);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyRed>(object, token);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyGreen>(object, token);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyBlue>(object, token);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyShininess>(object, token);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyHue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertySaturation>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyBrightness>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyRed>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyGreen>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyBlue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::addAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyShininess>(object, observer, userInfo);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyHue>(object, token);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertySaturation>(object, token);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyBrightness>(object, token);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyRed>(object, token);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyGreen>(object, token);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyBlue>(object, token);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::removeAnimatorBindingWillEmergeObserver<SPTAnimatableObjectPropertyShininess>(object, token);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyHue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertySaturation>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyBrightness>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyRed>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyGreen>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyBlue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyShininess>(object, observer, userInfo);
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
        case SPTAnimatableObjectPropertyHue: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyHue>(object, token);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertySaturation>(object, token);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyBrightness>(object, token);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyRed>(object, token);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyGreen>(object, token);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyBlue>(object, token);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyShininess>(object, token);
        }
    }
}
