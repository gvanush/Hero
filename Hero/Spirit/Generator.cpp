//
//  Generator.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.01.22.
//

#include "Generator.hpp"
#include "Generator.h"
#include "Scene.hpp"
#include "Transformation.hpp"
#include "MeshView.hpp"

SPTGeneratorBase SPTMakeGenerator(SPTObject object, SPTMeshId sourceMeshId, uint16_t quantity) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    auto& generator = registry.emplace<spt::Generator>(object.entity, SPTGeneratorBase{sourceMeshId, quantity});
    
    registry.create(generator.entities.begin(), generator.entities.end());
    spt::makeBlinnPhongMeshViews(registry, generator.entities, sourceMeshId, simd_float4 {1.f, 0.f, 0.f, 1.f}, 128.f);
    spt::makePositions(registry, generator.entities, simd_float3{});
    spt::makeScales(registry, generator.entities, simd_float3{20.f, 20.f, 20.f});
    return generator.base;
}

namespace spt {

Generator::Generator(SPTGeneratorBase b)
: base {b}
, entities {b.quantity, SPTEntity{entt::null}} {
}

void Generator::onDestroy(spt::Registry& registry, SPTEntity entity) {
    const auto& generator = registry.get<Generator>(entity);
    registry.destroy(generator.entities.begin(), generator.entities.end());
}

}
