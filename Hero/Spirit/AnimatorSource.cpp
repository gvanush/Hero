//
//  AnimatorSource.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 02.08.22.
//

#include "AnimatorSource.h"

bool SPTPanAnimatorSourcePanEqual(SPTPanAnimatorSource lhs, SPTPanAnimatorSource rhs) {
    return lhs.axis == rhs.axis && simd_equal(lhs.bottomLeft, rhs.bottomLeft) && simd_equal(lhs.topRight, rhs.topRight);
}

bool SPTRandomAnimatorSourceEqual(SPTRandomAnimatorSource lhs, SPTRandomAnimatorSource rhs) {
    return lhs.seed == rhs.seed && lhs.frequency == rhs.frequency;
}

bool SPTNoiseAnimatorSourceEqual(SPTNoiseAnimatorSource lhs, SPTNoiseAnimatorSource rhs) {
    return lhs.type == rhs.type && lhs.seed == rhs.seed && lhs.frequency == rhs.frequency && lhs.interpolation == rhs.interpolation;
}

bool SPTOscillatorAnimatorSourceEqual(SPTOscillatorAnimatorSource lhs, SPTOscillatorAnimatorSource rhs) {
    return lhs.frequency == rhs.frequency && lhs.interpolation == rhs.interpolation;
}

bool SPTAnimatorSourceEqual(SPTAnimatorSource lhs, SPTAnimatorSource rhs) {
    if(lhs.type != rhs.type) {
        return false;
    }
    
    switch (lhs.type) {
        case SPTAnimatorSourceTypePan: {
            return SPTPanAnimatorSourcePanEqual(lhs.pan, rhs.pan);
        }
        case SPTAnimatorSourceTypeRandom: {
            return SPTRandomAnimatorSourceEqual(lhs.random, rhs.random);
        }
        case SPTAnimatorSourceTypeNoise: {
            return SPTNoiseAnimatorSourceEqual(lhs.noise, rhs.noise);
        }
        case SPTAnimatorSourceTypeOscillator: {
            return SPTOscillatorAnimatorSourceEqual(lhs.oscillator, rhs.oscillator);
        }
    }
}
