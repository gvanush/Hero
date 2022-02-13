//
//  Transformation.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 16.11.21.
//

#pragma once

#include "Base.hpp"
#include "Base.h"

#include <simd/simd.h>

namespace spt {

struct Position {
    simd_float3 float3;
};


struct Scale {
    simd_float3 float3;
};


struct TransformationMatrix {
    simd_float4x4 float4x4;
    bool isDirty;
};

template <typename It, typename PG>
void makePositions(spt::Registry& registry, It beginEntity, It endEntity, std::size_t startIndex, PG positionGenerator) {
    auto index = startIndex;
    for(auto it = beginEntity; it != endEntity; ++it, ++index) {
        const auto entity = *it;
        registry.emplace<Position>(entity, positionGenerator(index));
        registry.emplace_or_replace<spt::TransformationMatrix>(entity, matrix_identity_float4x4, true);
    }
}

template <typename It, typename PG>
void updatePositions(spt::Registry& registry, It beginEntity, It endEntity, PG positionUpdater) {
    for(auto it = beginEntity; it != endEntity; ++it) {
        const auto entity = *it;
        registry.patch<Position>(entity, positionUpdater);
        registry.patch<spt::TransformationMatrix>(entity, [] (auto& tranMat) { tranMat.isDirty = true; });
    }
}

simd_float3 getPosition(SPTObject object);

simd_float3 getPosition(const spt::Registry& registry, SPTEntity entity);

template <typename It>
void makeScales(spt::Registry& registry, It beginEntity, It endEntity, simd_float3 scale) {
    registry.insert(beginEntity, endEntity, Scale{scale});
    for(auto it = beginEntity; it != endEntity; ++it) {
        registry.emplace_or_replace<spt::TransformationMatrix>(*it, matrix_identity_float4x4, true);
    }
}


const simd_float4x4* getTransformationMatrix(SPTObject object);
const simd_float4x4* getTransformationMatrix(spt::Registry& registry, SPTEntity entity);

}
