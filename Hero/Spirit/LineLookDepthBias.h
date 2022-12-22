//
//  LineLookDepthBias.h
//  Hero
//
//  Created by Vanush Grigoryan on 09.12.21.
//

#pragma once

#include "Base.h"

SPT_EXTERN_C_BEGIN

typedef struct {
    float bias;
    float slopeScale;
    float clamp;
} SPTLineLookDepthBias;

void SPTLineLookDepthBiasMake(SPTObject object, SPTLineLookDepthBias depthBias);

SPT_EXTERN_C_END
