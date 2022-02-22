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
#include "ComponentUpdateNotifier.hpp"
#include "BitByBitEquatable.hpp"

template <>
constexpr bool kBitByBitEquatable<SPTArrangement> = true;

namespace spt {

namespace {

void makeObjects(spt::Registry& registry, spt::Generator& generator, std::size_t count) {

    const auto initialSize = generator.entities.size();
    generator.entities.resize(generator.entities.size() + count);
    
    auto beginEntity = generator.entities.begin() + initialSize;
    registry.create(beginEntity, generator.entities.end());
    
    spt::makeBlinnPhongMeshViews(registry, beginEntity, generator.entities.end(), generator.base.sourceMeshId, simd_float4 {1.f, 0.f, 0.f, 1.f}, 128.f);
    
    switch (generator.base.arrangement.variantTag) {
        case SPTArrangementVariantTagLinear: {
            simd_float3 seedPosition {};
            seedPosition[generator.base.arrangement.linear.axis] = 15.0;
            spt::makePositions(registry, beginEntity, generator.entities.end(), initialSize, [seedPosition] (std::size_t i) {
                return SPTPosition {SPTPositionVariantTagXYZ, {.xyz = i * seedPosition}};
            });
            break;
        }
        default: {
            assert(false);
            break;
        }
    }
    
    spt::makeScales(registry, beginEntity, generator.entities.end(), simd_float3{5.f, 5.f, 5.f});
}

void destroyObjects(spt::Registry& registry, spt::Generator& generator, size_t count) {
    const auto countToDestroy = std::min(count, generator.entities.size());
    registry.destroy(generator.entities.end() - countToDestroy, generator.entities.end());
    generator.entities.resize(generator.entities.size() - countToDestroy);
}

void updateLinearAxis(spt::Registry& registry, const spt::Generator& generator, SPTAxis axis) {
    assert(generator.base.arrangement.variantTag == SPTArrangementVariantTagLinear);
    spt::updatePositions(registry, generator.entities.begin(), generator.entities.end(), [axis, &generator] (auto& position) {
        position.xyz[axis] = position.xyz[generator.base.arrangement.linear.axis];
        position.xyz[generator.base.arrangement.linear.axis] = 0.f;
    });
}

}

}

SPTGenerator SPTMakeGenerator(SPTObject object, SPTMeshId sourceMeshId, SPTGeneratorQuantityType quantity) {
    assert(quantity >= kSPTGeneratorMinQuantity && quantity <= kSPTGeneratorMaxQuantity);
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    
    // It is assumed that all the memory (including padding) of 'SPTGenerator' is zero initialized
    // for correct bit by bit equality comparison of underlying structs
    auto& generator = registry.emplace<spt::Generator>(object.entity);
    generator.base.quantity = quantity;
    generator.base.sourceMeshId = sourceMeshId;
    generator.base.arrangement.variantTag = SPTArrangementVariantTagLinear;
    generator.base.arrangement.linear.axis = SPTAxisX;

    spt::makeObjects(registry, generator, quantity);
    return generator.base;
}

SPTGenerator SPTGetGenerator(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<spt::Generator>(object.entity).base;
}

void SPTUpdateGenerator(SPTObject object, SPTGenerator updated) {
    
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<spt::Generator>::onWillChange(registry, object.entity);
    
    auto& generator = registry.get<spt::Generator>(object.entity);
    
    assert(updated.quantity >= kSPTGeneratorMinQuantity && updated.quantity <= kSPTGeneratorMaxQuantity);
    if(generator.base.quantity != updated.quantity) {
        if(updated.quantity > generator.base.quantity) {
            spt::makeObjects(registry, generator, updated.quantity - generator.base.quantity);
        } else {
            spt::destroyObjects(registry, generator, generator.base.quantity - updated.quantity);
        }
    }
    
    if(generator.base.sourceMeshId != updated.sourceMeshId) {
        spt::updateMeshViews(registry, generator.entities.begin(), generator.entities.end(), updated.sourceMeshId);
        generator.base.sourceMeshId = updated.sourceMeshId;
    }
    
    if(generator.base.arrangement != updated.arrangement) {
        
        // TODO
        if(generator.base.arrangement.variantTag != updated.arrangement.variantTag) {
            
        } else {
            if(generator.base.arrangement.linear.axis != updated.arrangement.linear.axis) {
                spt::updateLinearAxis(registry, generator, updated.arrangement.linear.axis);
            }
        }
        
    }
    
    generator.base = updated;
    
}

void SPTAddGeneratorWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::addComponentWillChangeListener<spt::Generator>(object, listener, callback);
}

void SPTRemoveGeneratorWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    spt::removeComponentWillChangeListenerCallback<spt::Generator>(object, listener, callback);
}

void SPTRemoveGeneratorWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<spt::Generator>(object, listener);
}

namespace spt {

void Generator::onDestroy(spt::Registry& registry, SPTEntity entity) {
    const auto& generator = registry.get<Generator>(entity);
    registry.destroy(generator.entities.begin(), generator.entities.end());
}

}
