//
//  MeshLook.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#pragma once

#include "Base.h"
#include "Base.hpp"
#include "MeshLook.h"

#include <vector>

namespace spt {

struct DirtyRenderableMaterialFlag {
};

namespace MeshLook {

void update(spt::Registry& registry);

void onDestroy(spt::Registry& registry, SPTEntity entity);

};

}

