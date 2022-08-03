//
//  AnimatorSource.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 02.08.22.
//

#include "AnimatorSource.h"

SPTAnimatorSource SPTAnimatorSourceMakePan(SPTPanAnimatorSourceAxis axis, simd_float2 bottomLeft, simd_float2 topRight) {
    return SPTAnimatorSource {SPTAnimatorSourceTypePan, {.pan = SPTAnimatorSourcePan {bottomLeft, topRight, axis}}};
}
