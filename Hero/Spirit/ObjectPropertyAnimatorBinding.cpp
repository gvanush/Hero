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
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyCartesianPositionX>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyCartesianPositionY>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyCartesianPositionZ>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyLinearPositionOffset>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::bindAnimator<SPTAnimatableObjectPropertySphericalPositionRadius>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::bindAnimator<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::bindAnimator<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyEulerOrientationX>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyEulerOrientationY>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyEulerOrientationZ>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyXYZScaleX>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyXYZScaleY>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyXYZScaleZ>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::bindAnimator<SPTAnimatableObjectPropertyUniformScale>(object, animatorBinding);
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
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionX>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionY>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionZ>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyLinearPositionOffset>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionRadius>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationX>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationY>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationZ>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleX>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleY>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleZ>(object, animatorBinding);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::updateAnimatorBinding<SPTAnimatableObjectPropertyUniformScale>(object, animatorBinding);
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
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyCartesianPositionX>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyCartesianPositionY>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyCartesianPositionZ>(object);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyLinearPositionOffset>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertySphericalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertySphericalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertySphericalPositionLatitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyEulerOrientationX>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyEulerOrientationY>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyEulerOrientationZ>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyXYZScaleX>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyXYZScaleY>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyXYZScaleZ>(object);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::unbindAnimator<SPTAnimatableObjectPropertyUniformScale>(object);
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

void SPTObjectPropertyUnbindAnimatorIfBound(SPTAnimatableObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyCartesianPositionX>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyCartesianPositionY>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyCartesianPositionZ>(object);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyLinearPositionOffset>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertySphericalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertySphericalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertySphericalPositionLatitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyEulerOrientationX>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyEulerOrientationY>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyEulerOrientationZ>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyXYZScaleX>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyXYZScaleY>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyXYZScaleZ>(object);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyUniformScale>(object);
        }
        case SPTAnimatableObjectPropertyHue: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyHue>(object);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertySaturation>(object);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyBrightness>(object);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyRed>(object);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyGreen>(object);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyBlue>(object);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::unbindAnimatorIfBound<SPTAnimatableObjectPropertyShininess>(object);
        }
    }
}

SPTAnimatorBinding SPTObjectPropertyGetAnimatorBinding(SPTAnimatableObjectProperty property, SPTObject object) {
    switch (property) {
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionX>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionY>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionZ>(object);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyLinearPositionOffset>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionLatitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationX>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationY>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationZ>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleX>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleY>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleZ>(object);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::getAnimatorBinding<SPTAnimatableObjectPropertyUniformScale>(object);
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
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionX>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionY>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionZ>(object);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyLinearPositionOffset>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertySphericalPositionLatitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationX>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationY>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationZ>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleX>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleY>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyXYZScaleZ>(object);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::tryGetAnimatorBinding<SPTAnimatableObjectPropertyUniformScale>(object);
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
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyCartesianPositionX>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyCartesianPositionY>(object);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyCartesianPositionZ>(object);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyLinearPositionOffset>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertySphericalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertySphericalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertySphericalPositionLatitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyEulerOrientationX>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyEulerOrientationY>(object);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyEulerOrientationZ>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyXYZScaleX>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyXYZScaleY>(object);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyXYZScaleZ>(object);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::isAnimatorBound<SPTAnimatableObjectPropertyUniformScale>(object);
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
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCartesianPositionX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCartesianPositionY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCartesianPositionZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyLinearPositionOffset>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertySphericalPositionRadius>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyEulerOrientationX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyEulerOrientationY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyEulerOrientationZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyXYZScaleX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyXYZScaleY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyXYZScaleZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::addAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyUniformScale>(object, observer, userInfo);
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
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCartesianPositionX>(object, token);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCartesianPositionY>(object, token);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCartesianPositionZ>(object, token);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyLinearPositionOffset>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertySphericalPositionRadius>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyEulerOrientationX>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyEulerOrientationY>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyEulerOrientationZ>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyXYZScaleX>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyXYZScaleY>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyXYZScaleZ>(object, token);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::removeAnimatorBindingWillChangeObserver<SPTAnimatableObjectPropertyUniformScale>(object, token);
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

SPTObserverToken SPTObjectPropertyAddAnimatorBindingDidChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingDidChangeObserver observer, SPTObserverUserInfo userInfo) {
    switch (property) {
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCartesianPositionX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCartesianPositionY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCartesianPositionZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyLinearPositionOffset>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertySphericalPositionRadius>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyEulerOrientationX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyEulerOrientationY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyEulerOrientationZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyXYZScaleX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyXYZScaleY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyXYZScaleZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyUniformScale>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyHue: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyHue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertySaturation>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyBrightness>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyRed>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyGreen>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyBlue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::addAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyShininess>(object, observer, userInfo);
        }
    }
}

void SPTObjectPropertyRemoveAnimatorBindingDidChangeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token) {
    switch (property) {
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCartesianPositionX>(object, token);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCartesianPositionY>(object, token);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCartesianPositionZ>(object, token);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyLinearPositionOffset>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertySphericalPositionRadius>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyEulerOrientationX>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyEulerOrientationY>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyEulerOrientationZ>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyXYZScaleX>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyXYZScaleY>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyXYZScaleZ>(object, token);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyUniformScale>(object, token);
        }
        case SPTAnimatableObjectPropertyHue: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyHue>(object, token);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertySaturation>(object, token);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyBrightness>(object, token);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyRed>(object, token);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyGreen>(object, token);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyBlue>(object, token);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::removeAnimatorBindingDidChangeObserver<SPTAnimatableObjectPropertyShininess>(object, token);
        }
    }
}

SPTObserverToken SPTObjectPropertyAddAnimatorBindingDidEmergeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingDidEmergeObserver observer, SPTObserverUserInfo userInfo) {
    switch (property) {
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCartesianPositionX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCartesianPositionY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCartesianPositionZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyLinearPositionOffset>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertySphericalPositionRadius>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyEulerOrientationX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyEulerOrientationY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyEulerOrientationZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyXYZScaleX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyXYZScaleY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyXYZScaleZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyUniformScale>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyHue: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyHue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertySaturation>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyBrightness>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyRed>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyGreen>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyBlue>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::addAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyShininess>(object, observer, userInfo);
        }
    }
}

void SPTObjectPropertyRemoveAnimatorBindingDidEmergeObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObserverToken token) {
    switch (property) {
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCartesianPositionX>(object, token);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCartesianPositionY>(object, token);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCartesianPositionZ>(object, token);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyLinearPositionOffset>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertySphericalPositionRadius>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyEulerOrientationX>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyEulerOrientationY>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyEulerOrientationZ>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyXYZScaleX>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyXYZScaleY>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyXYZScaleZ>(object, token);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyUniformScale>(object, token);
        }
        case SPTAnimatableObjectPropertyHue: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyHue>(object, token);
        }
        case SPTAnimatableObjectPropertySaturation: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertySaturation>(object, token);
        }
        case SPTAnimatableObjectPropertyBrightness: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyBrightness>(object, token);
        }
        case SPTAnimatableObjectPropertyRed: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyRed>(object, token);
        }
        case SPTAnimatableObjectPropertyGreen: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyGreen>(object, token);
        }
        case SPTAnimatableObjectPropertyBlue: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyBlue>(object, token);
        }
        case SPTAnimatableObjectPropertyShininess: {
            return spt::removeAnimatorBindingDidEmergeObserver<SPTAnimatableObjectPropertyShininess>(object, token);
        }
    }
}

SPTObserverToken SPTObjectPropertyAddAnimatorBindingWillPerishObserver(SPTAnimatableObjectProperty property, SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    switch (property) {
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCartesianPositionX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCartesianPositionY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCartesianPositionZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyLinearPositionOffset>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertySphericalPositionRadius>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyEulerOrientationX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyEulerOrientationY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyEulerOrientationZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyXYZScaleX>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyXYZScaleY>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyXYZScaleZ>(object, observer, userInfo);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::addAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyUniformScale>(object, observer, userInfo);
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
        case SPTAnimatableObjectPropertyCartesianPositionX: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCartesianPositionX>(object, token);
        }
        case SPTAnimatableObjectPropertyCartesianPositionY: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCartesianPositionY>(object, token);
        }
        case SPTAnimatableObjectPropertyCartesianPositionZ: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCartesianPositionZ>(object, token);
        }
        case SPTAnimatableObjectPropertyLinearPositionOffset: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyLinearPositionOffset>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionRadius: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertySphericalPositionRadius>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionLongitude: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertySphericalPositionLongitude>(object, token);
        }
        case SPTAnimatableObjectPropertySphericalPositionLatitude: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertySphericalPositionLatitude>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionRadius: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCylindricalPositionRadius>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionLongitude: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCylindricalPositionLongitude>(object, token);
        }
        case SPTAnimatableObjectPropertyCylindricalPositionHeight: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyCylindricalPositionHeight>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationX: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyEulerOrientationX>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationY: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyEulerOrientationY>(object, token);
        }
        case SPTAnimatableObjectPropertyEulerOrientationZ: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyEulerOrientationZ>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleX: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyXYZScaleX>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleY: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyXYZScaleY>(object, token);
        }
        case SPTAnimatableObjectPropertyXYZScaleZ: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyXYZScaleZ>(object, token);
        }
        case SPTAnimatableObjectPropertyUniformScale: {
            return spt::removeAnimatorBindingWillPerishObserver<SPTAnimatableObjectPropertyUniformScale>(object, token);
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
