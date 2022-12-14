//
//  Transformation.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 16.11.21.
//

#pragma once

#include "Base.hpp"
#include "Base.h"
#include "Transformation.h"
#include "Position.h"
#include "AnimatorBinding.hpp"

#include <simd/simd.h>

namespace spt {

struct DirtyTransformationFlag {
};

struct Transformation {
    
    simd_float4x4 local { matrix_identity_float4x4 };
    simd_float4x4 global { matrix_identity_float4x4 };
    SPTTranformationNode node { kSPTNullEntity, kSPTNullEntity, kSPTNullEntity, kSPTNullEntity, 0 };
    bool isGlobalMirroring { false };
    
    struct AnimatorRecord {
        
        struct PositionRecord {
            union {
                struct {
                    AnimatorBindingItemBase x;
                    AnimatorBindingItemBase y;
                    AnimatorBindingItemBase z;
                } cartesian;
                struct {
                    AnimatorBindingItemBase offset;
                } linear;
                struct {
                    AnimatorBindingItemBase radius;
                    AnimatorBindingItemBase longitude;
                    AnimatorBindingItemBase latitude;
                } spherical;
                struct {
                    AnimatorBindingItemBase radius;
                    AnimatorBindingItemBase longitude;
                    AnimatorBindingItemBase height;
                } cylindrical;
            };
        };
        
        PositionRecord positionRecord;
        SPTPosition basePosition;
        
        simd_float4x4 baseOrientation;
        
        simd_float3 baseScale;
    };
    
    static simd_float4x4 getGlobal(Registry& registry, SPTEntity entity);
    
    template <typename It>
    static void makeChildren(spt::Registry& registry, SPTEntity parent, It beginEntity, It endEntity);
    
    template <typename R, typename UF>
    static void forEachChild(R& registry, SPTEntity entity, UF unaryFunction);
        
    using GroupType = decltype(Registry().group<DirtyTransformationFlag, Transformation>());
    static void updateWithoutAnimators(Registry& registry, GroupType& group);
    
    using AnimatorsGroupType = decltype(Registry().group<AnimatorRecord, Transformation>());
    static void updateWithOnlyAnimatorsChanging(Registry& registry, AnimatorsGroupType& group, const std::vector<float> animatorValues);
    
    static void onDestroy(spt::Registry& registry, SPTEntity entity);
};

template <typename It>
void Transformation::makeChildren(spt::Registry& registry, SPTEntity parent, It beginEntity, It endEntity) {
    assert(registry.valid(parent));
    assert(checkValid(registry, beginEntity, endEntity));
    
    auto& parentTran = registry.get<Transformation>(parent);
    parentTran.node.childrenCount += std::distance(beginEntity, endEntity);
    
    for(auto it = beginEntity; it != endEntity; ++it) {
        
        const auto entity = *it;
        
        auto& tran = registry.emplace<Transformation>(entity);
        tran.node.parent = parent;
        tran.node.nextSibling = parentTran.node.firstChild;
        tran.node.level = parentTran.node.level + 1;

        if(parentTran.node.firstChild != kSPTNullEntity) {
            auto& firstChildTran = registry.get<Transformation>(parentTran.node.firstChild);
            firstChildTran.node.prevSibling = entity;
        }
        
        parentTran.node.firstChild = entity;
    }
}

template <typename R, typename UF>
void Transformation::forEachChild(R& registry, SPTEntity entity, UF unaryFunction) {
    
    auto nextChild = registry.template get<Transformation>(entity).node.firstChild;
    while(nextChild != kSPTNullEntity) {
        auto& childTran = registry.template get<Transformation>(nextChild);
        unaryFunction(nextChild, childTran);
        nextChild = childTran.node.nextSibling;
    }
    
}

}
