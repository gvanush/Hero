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
#include "AnimatorBinding.hpp"

#include <vector>

namespace spt {

struct DirtyRenderableMaterialFlag {
};

struct HSBColorAnimatorAnimatorRecord {
    AnimatorBindingItemBase hueItem;
    AnimatorBindingItemBase saturationItem;
    AnimatorBindingItemBase brightnessItem;
};

namespace MeshLook {

void update(spt::Registry& registry);
void updateWithOnlyAnimatorsChanging(spt::Registry& registry, const std::vector<float>& animatorValues);

void onDestroy(spt::Registry& registry, SPTEntity entity);

};

}

