//
//  Generator.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#pragma once

#include "Generator.h"
#include "Base.hpp"

#include <vector>
#include <entt/entt.hpp>

namespace spt {

struct Generator {
    SPTGenerator base;
    std::vector<SPTEntity> entities;
    
    static void onDestroy(spt::Registry& registry, SPTEntity entity);
};

};
