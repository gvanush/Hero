//
//  Metadata.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.03.22.
//

#include "Metadata.h"
#include "Scene.hpp"

#include <entt/entt.hpp>


void SPTMetadataMake(SPTObject object, SPTMetadata metadata) {
    spt::Scene::getRegistry(object).emplace<SPTMetadata>(object.entity, metadata);
}

SPTMetadata SPTMetadataGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTMetadata>(object.entity);
}
