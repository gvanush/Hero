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
    
    switch (generator.arrangement.variantTag) {
        case SPTArrangementVariantTagLinear: {
            simd_float3 seedPosition {};
            seedPosition[generator.arrangement.linear.axis] = 15.0;
            spt::makePositions(registry, beginEntity, generator.entities.end(), initialSize, [seedPosition] (std::size_t i) {
                return i * seedPosition;
            });
            break;
        }
        default: {
            assert(false);
            break;
        }
    }
    
    spt::makeScales(registry, beginEntity, generator.entities.end(), simd_float3{5.f, 5.f, 5.f});
    
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

void SPTUpdateLinearArrangementAxis(SPTObject object, SPTAxis axis) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    registry.patch<spt::Generator>(object.entity, [axis, &registry] (auto& generator) {
        assert(generator.arrangement.variantTag == SPTArrangementVariantTagLinear);
        spt::updatePositions(registry, generator.entities.begin(), generator.entities.end(), [axis, &generator] (auto& position) {
            position.float3[axis] = position.float3[generator.arrangement.linear.axis];
            position.float3[generator.arrangement.linear.axis] = 0.f;
        });
        generator.arrangement.linear.axis = axis;
    });
}

namespace spt {

Generator::Generator(SPTGeneratorBase b)
: base {b}
, arrangement {SPTArrangementVariantTagLinear, {.linear = { SPTAxisX }}} {
}

void Generator::onDestroy(spt::Registry& registry, SPTEntity entity) {
    const auto& generator = registry.get<Generator>(entity);
    registry.destroy(generator.entities.begin(), generator.entities.end());
}

}
