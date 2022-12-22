//
//  Position.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#pragma once

#include "Position.h"
#include "Base.hpp"
#include "Transformation.hpp"


namespace spt {

namespace Position {

template <typename It, typename PG>
void make(spt::Registry& registry, It beginEntity, It endEntity, std::size_t startIndex, PG positionGenerator) {
    auto index = startIndex;
    for(auto it = beginEntity; it != endEntity; ++it, ++index) {
        const auto entity = *it;
        spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, entity);
        registry.emplace<SPTPosition>(entity, positionGenerator(index));
    }
}

template <typename It, typename PG>
void update(spt::Registry& registry, It beginEntity, It endEntity, PG positionUpdater) {
    for(auto it = beginEntity; it != endEntity; ++it) {
        const auto entity = *it;
        spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, entity);
        registry.patch<SPTPosition>(entity, positionUpdater);
    }
}

simd_float3 getCartesianCoordinates(const spt::Registry& registry, SPTEntity entity);

}

}
