//
//  Scale.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#pragma once

#include "Base.hpp"
#include "Transformation.hpp"

namespace spt {

struct Scale {
    simd_float3 float3;
};

template <typename It>
void makeScales(spt::Registry& registry, It beginEntity, It endEntity, simd_float3 scale) {
    registry.insert(beginEntity, endEntity, Scale{scale});
    for(auto it = beginEntity; it != endEntity; ++it) {
        spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, *it);
    }
}

}
