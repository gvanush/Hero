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

template <typename VG>
void makePositions(spt::Registry& registry, std::vector<SPTEntity> entities, VG valueGenerator) {
    for(int i = 0; i < entities.size(); ++i) {
        const auto entity = entities[i];
        registry.emplace<Position>(entity, valueGenerator(i));
        registry.emplace_or_replace<spt::TransformationMatrix>(entity, matrix_identity_float4x4, true);
    }
}

simd_float3 getPosition(SPTObject object);

simd_float3 getPosition(const spt::Registry& registry, SPTEntity entity);


void makeScales(spt::Registry& registry, std::vector<SPTEntity> entities, simd_float3 scale);


const simd_float4x4* getTransformationMatrix(SPTObject object);
const simd_float4x4* getTransformationMatrix(spt::Registry& registry, SPTEntity entity);

}
