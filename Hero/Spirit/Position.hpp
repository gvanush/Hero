//
//  Position.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 22.02.22.
//

#pragma once

#include "Base.hpp"
#include "Transformation.hpp"

namespace spt {

template <typename It, typename PG>
void makePositions(spt::Registry& registry, It beginEntity, It endEntity, std::size_t startIndex, PG positionGenerator) {
    auto index = startIndex;
    for(auto it = beginEntity; it != endEntity; ++it, ++index) {
        const auto entity = *it;
        registry.emplace<SPTPosition>(entity, positionGenerator(index));
        registry.emplace_or_replace<spt::TransformationMatrix>(entity, matrix_identity_float4x4, true);
    }
}

template <typename It, typename PG>
void updatePositions(spt::Registry& registry, It beginEntity, It endEntity, PG positionUpdater) {
    for(auto it = beginEntity; it != endEntity; ++it) {
        const auto entity = *it;
        registry.get<spt::TransformationMatrix>(entity).isDirty = true;
        registry.patch<SPTPosition>(entity, positionUpdater);
    }
}

simd_float3 getPosition(SPTObject object);

simd_float3 getPosition(const spt::Registry& registry, SPTEntity entity);

}
