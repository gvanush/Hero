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
#include "RayCast.hpp"
#include "Scale.hpp"
#include "MeshLook.hpp"
#include "ComponentObserverUtil.hpp"


namespace spt {

namespace {

void makeObjects(spt::Registry& registry, SPTEntity entity, spt::Generator& generator, std::size_t count) {

    const auto initialSize = generator.entities.size();
    generator.entities.resize(generator.entities.size() + count);
    
    auto beginEntity = generator.entities.begin() + initialSize;
    registry.create(beginEntity, generator.entities.end());
    
    Transformation::makeChildren(registry, entity, beginEntity, generator.entities.end());
    
    MeshLook::makeBlinnPhong(registry, beginEntity, generator.entities.end(), generator.base.sourceMeshId, simd_float4 {1.f, 0.f, 0.f, 1.f}, 128.f);
    
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
    
    Scale::make(registry, beginEntity, generator.entities.end(), simd_float3{5.f, 5.f, 5.f});
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

void SPTGeneratorMake(SPTObject object, SPTGenerator base) {
    assert(base.quantity >= kSPTGeneratorMinQuantity && base.quantity <= kSPTGeneratorMaxQuantity);
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillEmergeObservers(registry, object.entity, base);
    
    auto& generator = registry.emplace<spt::Generator>(object.entity, base);
    
    spt::makeObjects(registry, object.entity, generator, base.quantity);
}

SPTGenerator SPTGeneratorGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<spt::Generator>(object.entity).base;
}

void SPTGeneratorUpdate(SPTObject object, SPTGenerator newGenerator) {
    
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, newGenerator);
    
    auto& generator = registry.get<spt::Generator>(object.entity);
    
    assert(newGenerator.quantity >= kSPTGeneratorMinQuantity && newGenerator.quantity <= kSPTGeneratorMaxQuantity);
    if(generator.base.quantity != newGenerator.quantity) {
        if(newGenerator.quantity > generator.base.quantity) {
            spt::makeObjects(registry, object.entity, generator, newGenerator.quantity - generator.base.quantity);
        } else {
            spt::destroyObjects(registry, generator, generator.base.quantity - newGenerator.quantity);
        }
    }
    
    if(generator.base.sourceMeshId != newGenerator.sourceMeshId) {
        spt::MeshLook::update(registry, generator.entities.begin(), generator.entities.end(), newGenerator.sourceMeshId);
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

void SPTGeneratorDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillPerishObservers<SPTPosition>(registry, object.entity);
    registry.erase<SPTGenerator>(object.entity);
}

const SPTGenerator* _Nullable SPTGeneratorTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTGenerator>(object.entity);
}

bool SPTGeneratorExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTGenerator>(object.entity);
}

SPTObserverToken SPTGeneratorAddWillChangeObserver(SPTObject object, SPTGeneratorWillChangeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTGenerator>(object, observer, userInfo);
}

void SPTGeneratorRemoveWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTGenerator>(object, token);
}

SPTObserverToken SPTGeneratorAddWillEmergeObserver(SPTObject object, SPTGeneratorWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillEmergeObserver<SPTGenerator>(object, observer, userInfo);
}

void SPTGeneratorRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillEmergeObserver<SPTGenerator>(object, token);
}

SPTObserverToken SPTGeneratorAddWillPerishObserver(SPTObject object, SPTGeneratorWillPerishObserver observer, SPTComponentObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTGenerator>(object, observer, userInfo);
}

void SPTGeneratorRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTGenerator>(object, token);
}
