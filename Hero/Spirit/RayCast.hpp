//
//  RayCast.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 05.03.22.
//

#pragma once

#include "RayCast.h"

namespace spt {

namespace RayCastableMesh {

template <typename It>
void make(spt::Registry& registry, It beginEntity, It endEntity, SPTMeshId meshId) {
    for(auto it = beginEntity; it != endEntity; ++it) {
        registry.emplace<SPTRayCastable>(*it, meshId);
    }
}

template <typename It>
void update(spt::Registry& registry, It beginEntity, It endEntity, SPTMeshId meshId) {
    for(auto it = beginEntity; it != endEntity; ++it) {
        registry.get<SPTRayCastable>(*it).meshId = meshId;
    }
}

}

}
