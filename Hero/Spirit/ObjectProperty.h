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
    SPTObjectPropertyPositionX,
    SPTObjectPropertyPositionY,
    SPTObjectPropertyPositionZ,
} __attribute__((enum_extensibility(open))) SPTObjectProperty;

SPT_EXTERN_C_END
