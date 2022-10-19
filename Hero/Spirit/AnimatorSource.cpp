//
//  AnimatorSource.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 02.08.22.
//

#include "AnimatorSource.h"


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
