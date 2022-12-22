//
//  Common.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 16.11.21.
//

#pragma once

#include "Base.h"

#include <entt/entt.hpp>
#include <simd/simd.h>

namespace spt {

constexpr size_t kMaxObserverCount = 8;

using Registry = entt::basic_registry<SPTEntity>;

using AnimatorRegistry = entt::basic_registry<SPTAnimatorId>;

template <typename EIt>
bool checkValid(const Registry& registry, EIt first, EIt last) {
    return std::all_of(first, last, [&registry] (const auto entity) { return registry.valid(entity); });
}

template <typename CT, typename R, typename E, typename... Args>
void emplaceIfMissing(R& registry, E entity, Args &&...args) {
    if(!registry.template all_of<CT>(entity)) {
        registry.template emplace<CT>(entity, std::forward<Args>(args)...);
    }
}

template <typename CT, typename R,  typename E>
CT update(R& registry, E entity, const CT& newValue) {
    auto& component = registry.template get<CT>(entity);
    auto old = component;
    component = newValue;
    return old;;
}

}
