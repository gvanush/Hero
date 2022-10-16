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

template <typename CT, typename... Args>
void emplaceIfMissing(Registry& registry, SPTEntity entity, Args &&...args) {
    if(!registry.all_of<CT>(entity)) {
        registry.emplace<CT>(entity, std::forward<Args>(args)...);
    }
}

}
