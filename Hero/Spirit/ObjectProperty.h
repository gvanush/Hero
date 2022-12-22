//
//  ObjectProperty.h
//  Hero
//
//  Created by Vanush Grigoryan on 16.08.22.
//

#pragma once

#include "Base.h"

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTAnimatableObjectPropertyCartesianPositionX,
    SPTAnimatableObjectPropertyCartesianPositionY,
    SPTAnimatableObjectPropertyCartesianPositionZ,
    
    SPTAnimatableObjectPropertyLinearPositionOffset,
    
    SPTAnimatableObjectPropertySphericalPositionRadius,
    SPTAnimatableObjectPropertySphericalPositionLongitude,
    SPTAnimatableObjectPropertySphericalPositionLatitude,
    
    SPTAnimatableObjectPropertyCylindricalPositionRadius,
    SPTAnimatableObjectPropertyCylindricalPositionLongitude,
    SPTAnimatableObjectPropertyCylindricalPositionHeight,
    
    SPTAnimatableObjectPropertyHue,
    SPTAnimatableObjectPropertySaturation,
    SPTAnimatableObjectPropertyBrightness,
    
    SPTAnimatableObjectPropertyRed,
    SPTAnimatableObjectPropertyGreen,
    SPTAnimatableObjectPropertyBlue,
    
    SPTAnimatableObjectPropertyShininess,
    
} __attribute__((enum_extensibility(closed))) SPTAnimatableObjectProperty;

SPT_EXTERN_C_END
