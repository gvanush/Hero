//
//  Scale.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#pragma once

#include "Base.hpp"
#include "Transformation.hpp"
#include "Scale.h"

namespace spt {

namespace Scale {
    
    template <typename It>
    static void make(spt::Registry& registry, It beginEntity, It endEntity, simd_float3 scale);
    
}

template <typename It>
void Scale::make(spt::Registry& registry, It beginEntity, It endEntity, simd_float3 scale) {
    registry.insert(beginEntity, endEntity, SPTScale{scale});
    for(auto it = beginEntity; it != endEntity; ++it) {
        spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, *it);
    }
}

}
