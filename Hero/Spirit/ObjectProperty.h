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
    SPTAnimatableObjectPropertyPositionX,
    SPTAnimatableObjectPropertyPositionY,
    SPTAnimatableObjectPropertyPositionZ,
    
    SPTAnimatableObjectPropertyHue,
    SPTAnimatableObjectPropertySaturation,
    SPTAnimatableObjectPropertyBrightness,
    
    SPTAnimatableObjectPropertyRed,
    SPTAnimatableObjectPropertyGreen,
    SPTAnimatableObjectPropertyBlue,
    
    SPTAnimatableObjectPropertyShininess,
    
} __attribute__((enum_extensibility(closed))) SPTAnimatableObjectProperty;

SPT_EXTERN_C_END
