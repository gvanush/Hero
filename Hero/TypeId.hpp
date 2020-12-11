//
//  TypeId.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/9/20.
//

#pragma once

#include <cstddef>

namespace hero {

using TypeId = std::size_t;

namespace _internal {

inline TypeId typeIdCount = 0;

}

template<typename T>
inline const TypeId typeIdOf = ++_internal::typeIdCount;

}
