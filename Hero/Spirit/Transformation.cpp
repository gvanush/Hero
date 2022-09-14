//
//  Transformation.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Transformation.hpp"
#include "Position.h"
#include "Position.hpp"
#include "Orientation.hpp"
#include "Scale.hpp"
#include "Scene.hpp"
#include "ComponentObserverUtil.hpp"
#include "Base.hpp"

#include <queue>

namespace spt {

namespace {

simd_float4x4 computeTransformationMatrix(const spt::Registry& registry, SPTEntity entity) {
    auto matrix = matrix_identity_float4x4;
    
    const auto& scale = spt::Scale::getXYZ(registry, entity);
    matrix.columns[0][0] = scale.x;
    matrix.columns[1][1] = scale.y;
    matrix.columns[2][2] = scale.z;
    
    const auto& pos = Position::getXYZ(registry, entity);
    
    matrix = simd_mul(Orientation::getMatrix(registry, entity, pos), matrix);
    
    matrix.columns[3].xyz = pos;
    
    return matrix;
}

simd_float4x4 computeTransformationMatrix(const spt::Registry& registry, SPTEntity entity, const Transformation::AnimatorRecord& animRecord, const std::vector<float> animatorValues) {
    
    auto matrix = animRecord.baseOrientation;
    
    matrix.columns[0][0] = animRecord.baseScale.x;
    matrix.columns[1][1] = animRecord.baseScale.y;
    matrix.columns[2][2] = animRecord.baseScale.z;
    
    const simd_float3 animatedPos {
        evaluateAnimatorBinding(animRecord.positionX.binding, animatorValues[animRecord.positionX.index]),
        evaluateAnimatorBinding(animRecord.positionY.binding, animatorValues[animRecord.positionY.index]),
        evaluateAnimatorBinding(animRecord.positionZ.binding, animatorValues[animRecord.positionZ.index])
    };
    const auto& pos = animRecord.basePosition + animatedPos;
    
    matrix = simd_mul(Orientation::getMatrix(registry, entity, pos), matrix);
    
    matrix.columns[3].xyz = pos;
    
    return matrix;
}

void removeFromParent(Registry& registry, SPTEntity entity, const Transformation& tran) {
    if(tran.node.parent == kSPTNullEntity) {
        return;
    }
    
    auto& oldParentTran = registry.get<spt::Transformation>(tran.node.parent);
    if(oldParentTran.node.firstChild == entity) {
        oldParentTran.node.firstChild = tran.node.nextSibling;
    }
    if(tran.node.nextSibling != kSPTNullEntity) {
        auto& nextSiblingTran = registry.get<spt::Transformation>(tran.node.nextSibling);
        nextSiblingTran.node.prevSibling = tran.node.prevSibling;
    }
    if(tran.node.prevSibling != kSPTNullEntity) {
        auto& prevSiblingTran = registry.get<spt::Transformation>(tran.node.prevSibling);
        prevSiblingTran.node.nextSibling = tran.node.nextSibling;
    }
    --oldParentTran.node.childrenCount;

}

}

simd_float4x4 Transformation::getGlobal(Registry& registry, SPTEntity entity) {
    
    auto nextEntity = entity;
    auto result = matrix_identity_float4x4;
    while (nextEntity != kSPTNullEntity) {
        const auto& local = (registry.all_of<DirtyTransformationFlag>(nextEntity) ?
                             computeTransformationMatrix(registry, nextEntity) :
                             registry.get<spt::Transformation>(nextEntity).local);
        result = simd_mul(local, result);
        nextEntity = registry.get<spt::Transformation>(nextEntity).node.parent;
    }
    
    return result;
}

void Transformation::updateWithoutAnimators(Registry& registry, GroupType& group) {
    
    // Sort so that parents are updated before their children
    group.sort<Transformation>([] (const auto& lhs, const auto& rhs) {
        return lhs.node.level < rhs.node.level;
    });
    
    // Recalculate matrices
    group.each([&registry, &group] (const auto entity, Transformation& tran) {
        
        tran.local = computeTransformationMatrix(registry, entity);
        if(tran.node.parent == kSPTNullEntity) {
            tran.global = tran.local;
        } else {
            tran.global = simd_mul(registry.get<Transformation>(tran.node.parent).global, tran.local);
        }
        
        // Update subtree
        // Prefering iterative over recursive algorithm to avoid stack overflow
        std::queue<SPTEntity> entityQueue;
        entityQueue.push(entity);
        while (!entityQueue.empty()) {

            const auto& parentTran = registry.get<Transformation>(entityQueue.front());
            forEachChild(registry, entityQueue.front(), [&registry, &entityQueue, &parentTran, &group] (auto childEntity, Transformation& childTran) {
                // If child is dirty it will be updated as part of outer loop
                if(!group.contains(childEntity)) {
                    childTran.global = simd_mul(parentTran.global, childTran.local);
                    entityQueue.push(childEntity);
                }
            });
            
            entityQueue.pop();
        }
        
    });
    
    registry.clear<DirtyTransformationFlag>();
}

void Transformation::updateWithOnlyAnimatorsChanging(Registry& registry, AnimatorsGroupType& group, const std::vector<float> animatorValues) {
    
    group.each([&registry, &group, &animatorValues] (const auto entity, AnimatorRecord& animRecord, Transformation& tran) {
        
        tran.local = computeTransformationMatrix(registry, entity, animRecord, animatorValues);
        if(tran.node.parent == kSPTNullEntity) {
            tran.global = tran.local;
        } else {
            tran.global = simd_mul(registry.get<Transformation>(tran.node.parent).global, tran.local);
        }
        
        // Update subtree
        // Prefering iterative over recursive algorithm to avoid stack overflow
        std::queue<SPTEntity> entityQueue;
        entityQueue.push(entity);
        while (!entityQueue.empty()) {

            const auto& parentTran = registry.get<Transformation>(entityQueue.front());
            forEachChild(registry, entityQueue.front(), [&registry, &entityQueue, &parentTran, &group] (auto childEntity, Transformation& childTran) {
                // If child has animators bound it will be updated as part of outer loop
                if(!group.contains(childEntity)) {
                    childTran.global = simd_mul(parentTran.global, childTran.local);
                    entityQueue.push(childEntity);
                }
            });
            
            entityQueue.pop();
        }
        
    });
    
}

void Transformation::onDestroy(spt::Registry& registry, SPTEntity entity) {
    auto& tran = registry.get<Transformation>(entity);
    removeFromParent(registry, entity, tran);
    registry.remove<DirtyTransformationFlag>(entity);
}

}


// MARK: Public
SPTTranformationNode SPTTransformationGetNode(SPTObject object) {
    if(const auto transformation = spt::Scene::getRegistry(object).try_get<spt::Transformation>(object.entity)) {
        return transformation->node;
    }
    return SPTTranformationNode {kSPTNullEntity, kSPTNullEntity, kSPTNullEntity, kSPTNullEntity};
}

void SPTTransformationSetParent(SPTObject object, SPTEntity parentEntity) {
    assert(object.entity != parentEntity);
    assert(!SPTIsNull(object));
    assert(!SPTTransformationIsDescendant(SPTObject {parentEntity, object.sceneHandle}, object));
    
    auto& registry = spt::Scene::getRegistry(object);
    assert(registry.valid(parentEntity));
    
    auto& tran = registry.get<spt::Transformation>(object.entity);
    
    if(tran.node.parent == parentEntity) {
        return;
    }
    
    // Remove from current parent
    spt::removeFromParent(registry, object.entity, tran);
    
    // Add to new parent
    tran.node.prevSibling = kSPTNullEntity;
    if(parentEntity == kSPTNullEntity) {
        tran.node.nextSibling = kSPTNullEntity;
        tran.node.level = 0;
    } else {
        auto& parentTran = registry.get<spt::Transformation>(parentEntity);
        tran.node.nextSibling = parentTran.node.firstChild;
        
        auto& firstChildTran = registry.get<spt::Transformation>(parentTran.node.firstChild);
        firstChildTran.node.prevSibling = object.entity;
        
        parentTran.node.firstChild = object.entity;
        ++parentTran.node.childrenCount;
        tran.node.level = parentTran.node.level + 1;
    }
    
    tran.node.parent = parentEntity;
    
    spt::emplaceIfMissing<spt::DirtyTransformationFlag>(registry, object.entity);
}

bool SPTTransformationIsDescendant(SPTObject object, SPTObject ancestor) {
    assert(object.sceneHandle == ancestor.sceneHandle);
    assert(!SPTIsNull(ancestor));
    
    const auto& registry = spt::Scene::getRegistry(object);
    auto nextAncestorEntity = object.entity;
    while (nextAncestorEntity != kSPTNullEntity) {
        nextAncestorEntity = registry.get<spt::Transformation>(nextAncestorEntity).node.parent;
        if(nextAncestorEntity == ancestor.entity) {
            return true;
        }
    }
    return false;
}
