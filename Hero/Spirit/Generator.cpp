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
#include "ComponentListenerUtil.hpp"

namespace spt {

namespace {

void makeObjects(spt::Registry& registry, spt::Generator& generator, std::size_t count) {

    const auto initialSize = generator.entities.size();
    generator.entities.resize(generator.entities.size() + count);
    
    auto beginEntity = generator.entities.begin() + initialSize;
    registry.create(beginEntity, generator.entities.end());
    
    spt::makeBlinnPhongMeshViews(registry, beginEntity, generator.entities.end(), generator.base.sourceMeshId, simd_float4 {1.f, 0.f, 0.f, 1.f}, 128.f);
    spt::makePositions(registry, beginEntity, generator.entities.end(), initialSize, [] (std::size_t i) {
        return simd_float3 {50.f * i, 0.f, 0.f};
    });
    spt::makeScales(registry, beginEntity, generator.entities.end(), simd_float3{20.f, 20.f, 20.f});
    
    generator.base.quantity = generator.entities.size();
    
}

void destroyObjects(spt::Registry& registry, spt::Generator& generator, size_t count) {
    
    const auto countToDestroy = std::min(count, generator.entities.size());
    registry.destroy(generator.entities.end() - countToDestroy, generator.entities.end());
    generator.entities.resize(generator.entities.size() - countToDestroy);
    generator.base.quantity = generator.entities.size();
    
}

}

}

SPTGeneratorBase SPTMakeGenerator(SPTObject object, SPTMeshId sourceMeshId, SPTGeneratorQuantityType quantity) {
    assert(quantity >= kSPTGeneratorMinQuantity && quantity <= kSPTGeneratorMaxQuantity);
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    auto& generator = registry.emplace<spt::Generator>(object.entity, SPTGeneratorBase{sourceMeshId, quantity});
    spt::makeObjects(registry, generator, quantity);
    return generator.base;
}

SPTGeneratorBase SPTGetGenerator(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<spt::Generator>(object.entity).base;
}

void SPTUpdateGeneratorSourceMesh(SPTObject object, SPTMeshId sourceMeshId) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::Generator>(object.entity, [sourceMeshId] (auto& generator) {
        generator.base.sourceMeshId = sourceMeshId;
    });
    auto& generator = registry.get<spt::Generator>(object.entity);
    spt::updateMeshViews(registry, generator.entities, sourceMeshId);
}

void SPTUpdateGeneratorQunatity(SPTObject object, SPTGeneratorQuantityType quantity) {
    assert(quantity >= kSPTGeneratorMinQuantity && quantity <= kSPTGeneratorMaxQuantity);
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::Generator>(object.entity, [quantity, &registry] (auto& generator) {
        if(quantity > generator.base.quantity) {
            spt::makeObjects(registry, generator, quantity - generator.base.quantity);
        } else {
            spt::destroyObjects(registry, generator, generator.base.quantity - quantity);
        }
    });
}

void SPTAddGeneratorListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentListener<spt::Generator>(object, listener, callback);
}

void SPTRemoveGeneratorListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentListenerCallback<spt::Generator>(object, listener, callback);
}

void SPTRemoveGeneratorListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentListener<spt::Generator>(object, listener);
}

namespace spt {

Generator::Generator(SPTGeneratorBase b)
: base {b} {
}

void Generator::onDestroy(spt::Registry& registry, SPTEntity entity) {
    const auto& generator = registry.get<Generator>(entity);
    registry.destroy(generator.entities.begin(), generator.entities.end());
}

}
