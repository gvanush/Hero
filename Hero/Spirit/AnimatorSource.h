//
//  AnimatorSource.h
//  Hero
//
//  Created by Vanush Grigoryan on 02.08.22.
//

#pragma once

#include "Base.h"
#include "Easing.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTAnimatorSourceTypePan,
    SPTAnimatorSourceTypeRandom,
    SPTAnimatorSourceTypeNoise,
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
    uint32_t seed;
    float frequency;
} SPTAnimatorSourceRandom;

typedef struct {
    uint32_t seed;
    float frequency;
    SPTEasingType interpolation;
} SPTAnimatorSourceNoise;

typedef struct {
    SPTAnimatorSourceType type;
    union {
        SPTAnimatorSourcePan pan;
        SPTAnimatorSourceRandom random;
        SPTAnimatorSourceNoise noise;
    };
} SPTAnimatorSource;

bool SPTAnimatorSourceEqual(SPTAnimatorSource lhs, SPTAnimatorSource rhs);

SPT_EXTERN_C_END
