//
//  Easing.h
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.22.
//

#pragma once

#include "Base.h"

#include <simd/simd.h>


SPT_EXTERN_C_BEGIN

typedef enum {
    SPTEasingTypeLinear,
    SPTEasingTypeSmoothStep,
    SPTEasingTypeSmootherStep,
} __attribute__((enum_extensibility(closed))) SPTEasingType;

inline float SPTEasingEvaluateLinear(float x) {
    return x;
}

inline float SPTEasingEvaluateSmoothStep(float x) {
    return x * x * (3.f - 2.f * x);
}

inline float SPTEasingEvaluateSmootherStep(float x) {
    return x * x * x * (x * (x * 6 - 15) + 10);
}

inline float SPTEasingEvaluate(SPTEasingType type, float x) {
    switch (type) {
        case SPTEasingTypeLinear:
            return SPTEasingEvaluateLinear(x);
        case SPTEasingTypeSmoothStep:
            return SPTEasingEvaluateSmoothStep(x);
        case SPTEasingTypeSmootherStep:
            return SPTEasingEvaluateSmootherStep(x);
    }
}

SPT_EXTERN_C_END
