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

using Registry = entt::basic_registry<SPTEntity>;
using EntityObserver = entt::basic_observer<SPTEntity>;

template <typename CT, typename... Args>
void emplaceIfMissing(Registry& registry, SPTEntity entity, Args &&...args) {
    if(!registry.all_of<CT>(entity)) {
        registry.emplace<CT>(entity, std::forward<Args>(args)...);
    }
}

struct ComponentListenerItem {
    SPTComponentListener listener;
    SPTComponentListenerCallback callback;
};

template <typename CT>
struct Observable {
    std::vector<ComponentListenerItem> willChangeListeners;
};

}
