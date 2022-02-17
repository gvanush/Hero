//
//  BitByBitEquatable.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.02.22.
//

#pragma once

#include <type_traits>
#include <cstring>


template <typename T>
constexpr bool kBitByBitEquatable = false;

template <typename T>
std::enable_if_t<kBitByBitEquatable<T>, bool> operator==(const T& l, const T& r) {
    return std::memcmp(&l, &r, sizeof(T)) == 0;
}

template <typename T>
bool operator!=(const T& l, const T& r) {
    return !(l == r);
}
