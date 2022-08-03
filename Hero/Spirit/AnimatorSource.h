//
//  AnimatorSource.h
//  Hero
//
//  Created by Vanush Grigoryan on 02.08.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTAnimatorSourceTypePan,
    SPTAnimatorSourceTypeFace,
} __attribute__((enum_extensibility(open))) SPTAnimatorSourceType;

typedef enum {
    SPTPanAnimatorSourceAxisHorizontal,
    SPTPanAnimatorSourceAxisVertical
} __attribute__((enum_extensibility(closed))) SPTPanAnimatorSourceAxis;

typedef struct {
    simd_float2 bottomLeft;
    simd_float2 topRight;
    SPTPanAnimatorSourceAxis axis;
} SPTAnimatorSourcePan;

typedef struct {
    SPTAnimatorSourceType type;
    union {
        SPTAnimatorSourcePan pan;
    };
} SPTAnimatorSource;

SPTAnimatorSource SPTAnimatorSourceMakePan(SPTPanAnimatorSourceAxis axis, simd_float2 bottomLeft, simd_float2 topRight);

SPT_EXTERN_C_END
