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
#include "Position.hpp"
#include "Scale.hpp"
#include "MeshView.hpp"
#include "ComponentListenerUtil.hpp"
#include "ComponentUpdateNotifier.hpp"


namespace spt {

namespace {

void makeObjects(spt::Registry& registry, SPTObject object, spt::Generator& generator, std::size_t count) {

    const auto initialSize = generator.entities.size();
    generator.entities.resize(generator.entities.size() + count);
    
    auto beginEntity = generator.entities.begin() + initialSize;
    registry.create(beginEntity, generator.entities.end());
    
    Transformation::makeChildren(registry, object, beginEntity, generator.entities.end());
    
    spt::MeshView::makeBlinnPhong(registry, beginEntity, generator.entities.end(), generator.base.sourceMeshId, simd_float4 {1.f, 0.f, 0.f, 1.f}, 128.f);
    
    switch (generator.base.arrangement.variantTag) {
        case SPTArrangementVariantTagLinear: {
            simd_float3 seedPosition {};
            seedPosition[generator.base.arrangement.linear.axis] = 15.0;
            spt::Position::make(registry, beginEntity, generator.entities.end(), initialSize, [seedPosition] (std::size_t i) {
                return SPTPosition {SPTPositionVariantTagXYZ, {.xyz = i * seedPosition}};
            });
            break;
        }
        default: {
            assert(false);
            break;
        }
    }
    
    spt::Scale::make(registry, beginEntity, generator.entities.end(), simd_float3{5.f, 5.f, 5.f});
}

void destroyObjects(spt::Registry& registry, spt::Generator& generator, size_t count) {
    const auto countToDestroy = std::min(count, generator.entities.size());
    registry.destroy(generator.entities.end() - countToDestroy, generator.entities.end());
    generator.entities.resize(generator.entities.size() - countToDestroy);
}

void updateLinearAxis(spt::Registry& registry, const spt::Generator& generator, SPTAxis axis) {
    assert(generator.base.arrangement.variantTag == SPTArrangementVariantTagLinear);
    spt::Position::update(registry, generator.entities.begin(), generator.entities.end(), [axis, &generator] (auto& position) {
        position.xyz[axis] = position.xyz[generator.base.arrangement.linear.axis];
        position.xyz[generator.base.arrangement.linear.axis] = 0.f;
    });
}

}

void Generator::onDestroy(spt::Registry& registry, SPTEntity entity) {
    const auto& generator = registry.get<Generator>(entity);
    for(auto genEntity: generator.entities) {
        if(registry.valid(genEntity)) {
            registry.destroy(genEntity);
        }
    }
}

}

bool SPTGeneratorEqual(SPTGenerator lhs, SPTGenerator rhs) {
    return lhs.quantity == rhs.quantity &&
    lhs.sourceMeshId == rhs.sourceMeshId &&
    SPTArrangementEqual(lhs.arrangement, rhs.arrangement);
}

SPTGenerator SPTGeneratorMake(SPTObject object, SPTMeshId sourceMeshId, SPTGeneratorQuantityType quantity) {
    assert(quantity >= kSPTGeneratorMinQuantity && quantity <= kSPTGeneratorMaxQuantity);
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    
    // It is assumed that all the memory (including padding) of 'SPTGenerator' is zero initialized
    // for correct bit by bit equality comparison of underlying structs
    auto& generator = registry.emplace<spt::Generator>(object.entity);
    generator.base.quantity = quantity;
    generator.base.sourceMeshId = sourceMeshId;
    generator.base.arrangement.variantTag = SPTArrangementVariantTagLinear;
    generator.base.arrangement.linear.axis = SPTAxisX;
    
    spt::makeObjects(registry, object, generator, quantity);
    return generator.base;
}

SPTGenerator SPTGeneratorGet(SPTObject object) {
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    return registry.get<spt::Generator>(object.entity).base;
}

void SPTGeneratorUpdate(SPTObject object, SPTGenerator newGenerator) {
    
    auto& registry = static_cast<spt::Scene*>(object.sceneHandle)->registry;
    spt::ComponentUpdateNotifier<SPTGenerator>::onWillChange(registry, object.entity, newGenerator);
    
    auto& generator = registry.get<spt::Generator>(object.entity);
    
    assert(newGenerator.quantity >= kSPTGeneratorMinQuantity && newGenerator.quantity <= kSPTGeneratorMaxQuantity);
    if(generator.base.quantity != newGenerator.quantity) {
        if(newGenerator.quantity > generator.base.quantity) {
            spt::makeObjects(registry, object, generator, newGenerator.quantity - generator.base.quantity);
        } else {
            spt::destroyObjects(registry, generator, generator.base.quantity - newGenerator.quantity);
        }
    }
    
    if(generator.base.sourceMeshId != newGenerator.sourceMeshId) {
        spt::MeshView::update(registry, generator.entities.begin(), generator.entities.end(), newGenerator.sourceMeshId);
        generator.base.sourceMeshId = newGenerator.sourceMeshId;
    }
    
    if(!SPTArrangementEqual(generator.base.arrangement, newGenerator.arrangement)) {
        
        // TODO
        if(generator.base.arrangement.variantTag != newGenerator.arrangement.variantTag) {
            
        } else {
            if(generator.base.arrangement.linear.axis != newGenerator.arrangement.linear.axis) {
                spt::updateLinearAxis(registry, generator, newGenerator.arrangement.linear.axis);
            }
        }
        
    }
    
    generator.base = newGenerator;
    
}

void SPTGeneratorAddWillChangeListener(SPTObject object, SPTComponentListener listener, SPTGeneratorWillChangeCallback callback) {
    spt::addComponentWillChangeListener<SPTGenerator>(object, listener, callback);
}

void SPTGeneratorRemoveWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTGeneratorWillChangeCallback callback) {
    spt::removeComponentWillChangeListenerCallback<SPTGenerator>(object, listener, callback);
}

void SPTGeneratorRemoveWillChangeListener(SPTObject object, SPTComponentListener listener) {
    spt::removeComponentWillChangeListener<spt::Generator>(object, listener);
}
