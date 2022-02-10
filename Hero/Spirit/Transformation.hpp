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


void makePositions(spt::Registry& registry, std::vector<SPTEntity> entities, simd_float3 position);

template <typename It, typename VG>
void makePositions(spt::Registry& registry, It beginEntity, It endEntity, std::size_t startIndex, VG valueGenerator) {
    auto index = startIndex;
    for(auto it = beginEntity; it != endEntity; ++it, ++index) {
        const auto entity = *it;
        registry.emplace<Position>(entity, valueGenerator(index));
        registry.emplace_or_replace<spt::TransformationMatrix>(entity, matrix_identity_float4x4, true);
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
