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
    SPTAnimatorSourceTypeOscillator,
} __attribute__((enum_extensibility(open))) SPTAnimatorSourceType;

typedef enum {
    SPTPanAnimatorSourceAxisHorizontal,
    SPTPanAnimatorSourceAxisVertical
} __attribute__((enum_extensibility(closed))) SPTPanAnimatorSourceAxis;

typedef struct {
    simd_float2 bottomLeft;
    simd_float2 topRight;
    SPTPanAnimatorSourceAxis axis;
} SPTPanAnimatorSource;

bool SPTPanAnimatorSourceEqual(SPTPanAnimatorSource lhs, SPTPanAnimatorSource rhs);

typedef struct {
    uint32_t seed;
    float frequency;
} SPTRandomAnimatorSource;

bool SPTRandomAnimatorSourceEqual(SPTRandomAnimatorSource lhs, SPTRandomAnimatorSource rhs);

typedef enum {
    SPTNoiseTypeValue,
    SPTNoiseTypePerlin
} __attribute__((enum_extensibility(closed))) SPTNoiseType;

typedef struct {
    SPTNoiseType type;
    uint32_t seed;
    float frequency;
    SPTEasingType interpolation;
} SPTNoiseAnimatorSource;

bool SPTNoiseAnimatorSourceEqual(SPTNoiseAnimatorSource lhs, SPTNoiseAnimatorSource rhs);

typedef struct {
    float frequency;
    SPTEasingType interpolation;
} SPTOscillatorAnimatorSource;

bool SPTOscillatorAnimatorSourceEqual(SPTOscillatorAnimatorSource lhs, SPTOscillatorAnimatorSource rhs);

typedef struct {
    SPTAnimatorSourceType type;
    union {
        SPTPanAnimatorSource pan;
        SPTRandomAnimatorSource random;
        SPTNoiseAnimatorSource noise;
        SPTOscillatorAnimatorSource oscillator;
    };
} SPTAnimatorSource;

bool SPTAnimatorSourceEqual(SPTAnimatorSource lhs, SPTAnimatorSource rhs);

SPT_EXTERN_C_END
