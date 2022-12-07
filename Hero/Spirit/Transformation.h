//
//  Transformation.h
//  Hero
//
//  Created by Vanush Grigoryan on 23.02.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>


SPT_EXTERN_C_BEGIN

typedef struct {
    SPTEntity parent;
    SPTEntity prevSibling;
    SPTEntity nextSibling;
    SPTEntity firstChild;
    uint16_t childrenCount;
    uint16_t level;
} SPTTranformationNode;


SPTTranformationNode SPTTransformationGetNode(SPTObject object);

void SPTTransformationSetParent(SPTObject object, SPTEntity parentEntity);

bool SPTTransformationIsDescendant(SPTObject object, SPTObject ancestor);

simd_float4x4 SPTTransformationGetLocal(SPTObject object);

SPT_EXTERN_C_END
