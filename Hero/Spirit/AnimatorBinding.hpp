//
//  AnimatorBinding.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 13.09.22.
//

#pragma once

#include "AnimatorBinding.h"

#include <simd/simd.h>

namespace spt {

struct AnimatorBindingItem {
    SPTAnimatorBinding binding;
    size_t index;
};

inline float evaluateAnimatorBinding(SPTAnimatorBinding binding, float animatorValue) {
    return simd_mix(binding.valueAt0, binding.valueAt1, animatorValue);
}

}
