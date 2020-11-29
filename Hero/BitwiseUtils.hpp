//
//  BitwiseUtils.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 11/28/20.
//

#pragma once

#include <type_traits>

namespace hero {

template <typename T>
std::enable_if_t<std::is_unsigned_v<T>, std::size_t> lastBitPosition(T num) {
    std::size_t i = 0;
    num >>= 1;
    while (num) {
        ++i;
        num >>= 1;
    }
    return i;
}

}
