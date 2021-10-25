//
//  Numeric.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/5/20.
//

#pragma once

namespace hero {

inline bool areNearlyEqual(float n1, float n2, float tolerance) {
    return fabsf(n1 - n2) <= tolerance;
}

inline bool isNearlyZero(float n, float tolerance) {
    return fabsf(n) <= tolerance;
}

}

