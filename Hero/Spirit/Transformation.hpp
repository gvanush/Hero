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

#include <simd/simd.h>

namespace spt {

struct DirtyTransformationFlag {
};

struct Transformation {
    simd_float4x4 local { matrix_identity_float4x4 };
    simd_float4x4 global { matrix_identity_float4x4 };
    SPTTranformationNode node { kSPTNullEntity, kSPTNullEntity, kSPTNullEntity, kSPTNullEntity, 0 };
    
    using GroupType = decltype(Registry().group<DirtyTransformationFlag, Transformation>());
    
    static simd_float4x4 getGlobal(Registry& registry, SPTEntity entity);
    
    template <typename It>
    static void makeChildren(spt::Registry& registry, SPTEntity parent, It beginEntity, It endEntity);
    
    template <typename UF>
    static void forEachChild(Registry& registry, SPTEntity entity, UF unaryFunction);
    
    static void update(Registry& registry, GroupType& group);
    
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

template <typename UF>
void Transformation::forEachChild(Registry& registry, SPTEntity entity, UF unaryFunction) {
    
    auto nextChild = registry.get<Transformation>(entity).node.firstChild;
    while(nextChild != kSPTNullEntity) {
        auto& childTran = registry.get<Transformation>(nextChild);
        unaryFunction(nextChild, childTran);
        nextChild = childTran.node.nextSibling;
    }
    
}

}
