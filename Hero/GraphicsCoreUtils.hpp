//
//  GraphicsCoreUtils.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/11/20.
//

#pragma once

#include <type_traits>

namespace hero {

class Component;
class CompositeComponent;

template <typename CT>
constexpr bool isConcreteComponent = std::is_base_of_v<Component, CT> && !std::is_same_v<CompositeComponent, CT>;

enum class ComponentState {
    new_,
    active,
    removed
};

enum class ComponentCategory {
    basic,
    renderer
};

using StepNumber = std::size_t;

}