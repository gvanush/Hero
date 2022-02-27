//
//  Transformation.h
//  Hero
//
//  Created by Vanush Grigoryan on 23.02.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

typedef struct {
    SPTObject parent;
    SPTObject prevSibling;
    SPTObject nextSibling;
    SPTObject firstChild;
    uint16_t childrenCount;
    uint16_t level;
} SPTTranformationNode;


SPTTranformationNode SPTTransformationGetNode(SPTObject object);

void SPTTransformationSetParent(SPTObject object, SPTObject parent);

bool SPTTransformationIsDescendant(SPTObject object, SPTObject ancestor);
