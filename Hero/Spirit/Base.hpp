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

struct ComponentListenerItem {
    SPTComponentListener listener;
    SPTComponentListenerCallback callback;
};

template <typename CT>
struct Observable {
    std::vector<ComponentListenerItem> willChangeListeners;
};

}
