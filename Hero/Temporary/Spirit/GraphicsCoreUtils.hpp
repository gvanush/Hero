//
//  GraphicsCoreUtils.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/11/20.
//

#pragma once

#include <type_traits>
#include <cstdint>

namespace hero {

class Component;
class CompositeComponent;

template <typename CT>
constexpr bool isConcreteComponent = std::is_base_of_v<Component, CT> && !std::is_same_v<Component, CT>;

template <typename CT>
constexpr bool isCompositeComponent = std::is_base_of_v<CompositeComponent, CT>;

enum class ComponentState {
    active,
    removed
};

enum class ComponentCategory {
    basic,
    renderer
};

using StepNumber = std::size_t;

enum Layer: unsigned int {
    kLayerContent = 0,
    kLayerUI,
    
    _kLayerCount
};

}
