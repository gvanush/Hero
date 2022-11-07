//
//  Color.h
//  Hero
//
//  Created by Vanush Grigoryan on 05.11.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>

SPT_EXTERN_C_BEGIN

typedef enum {
    SPTColorModelRGB,
    SPTColorModelHSB
} __attribute__((enum_extensibility(closed))) SPTColorModel;

typedef union {
    simd_float4 float4;
    struct {
        float red;
        float green;
        float blue;
        float alpha;
    };
} SPTRGBAColor;

bool SPTRGBAColorValidate(SPTRGBAColor color);

bool SPTRGBAColorEqual(SPTRGBAColor lhs, SPTRGBAColor rhs);

typedef union {
    simd_float4 float4;
    struct {
        float hue;
        float saturation;
        float brightness;
        float alpha;
    };
} SPTHSBAColor;

bool SPTHSBAColorValidate(SPTHSBAColor color);

bool SPTHSBAColorEqual(SPTHSBAColor lhs, SPTHSBAColor rhs);

SPTHSBAColor SPTRGBAColorToHSBA(SPTRGBAColor rgba);
SPTRGBAColor SPTHSBAColorToRGBA(SPTHSBAColor hsba);


typedef struct {
    SPTColorModel model;
    union {
        SPTRGBAColor rgba;
        SPTHSBAColor hsba;
    };
} SPTColor;

bool SPTColorValidate(SPTColor color);

bool SPTColorEqual(SPTColor lhs, SPTColor rhs);

SPTColor SPTColorToRGBA(SPTColor color);
SPTColor SPTColorToHSBA(SPTColor color);


SPT_EXTERN_C_END
