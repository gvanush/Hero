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

SPTAnimatorSource SPTAnimatorSourceMakeRandom(uint32_t seed) {
    return SPTAnimatorSource {SPTAnimatorSourceTypeRandom, {.random = SPTAnimatorSourceRandom {seed}}};
}

bool SPTAnimatorSourceEqual(SPTAnimatorSource lhs, SPTAnimatorSource rhs) {
    if(lhs.type != rhs.type) {
        return false;
    }
    
    switch (lhs.type) {
        case SPTAnimatorSourceTypePan: {
            return lhs.pan.axis == rhs.pan.axis && simd_equal(lhs.pan.bottomLeft, rhs.pan.bottomLeft) && simd_equal(lhs.pan.topRight, rhs.pan.topRight);
        }
        case SPTAnimatorSourceTypeRandom: {
            return lhs.random.seed == rhs.random.seed;
        }
    }
}
