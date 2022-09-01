//
//  MeshLook.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#include "MeshLook.h"
#include "MeshLook.hpp"
#include "Scene.hpp"


bool SPTMeshLookEqual(SPTMeshLook lhs, SPTMeshLook rhs) {
    if(lhs.shading != rhs.shading || lhs.meshId != rhs.meshId || lhs.categories != rhs.categories) {
        return false;
    }
    switch (lhs.shading) {
        case SPTMeshShadingPlainColor: {
            return SPTPlainColorMaterialEqual(lhs.plainColor, rhs.plainColor);
        }
        case SPTMeshShadingBlinnPhong: {
            return SPTPhongMaterialEqual(lhs.blinnPhong, rhs.blinnPhong);
        }
    }
}

void SPTMeshLookMake(SPTObject object, SPTMeshLook meshLook) {
    spt::Scene::getRegistry(object).emplace<SPTMeshLook>(object.entity, meshLook);
}

void SPTMeshLookUpdate(SPTObject object, SPTMeshLook meshLook) {
    spt::Scene::getRegistry(object).get<SPTMeshLook>(object.entity) = meshLook;
}

void SPTMeshLookDestroy(SPTObject object) {
    spt::Scene::getRegistry(object).erase<SPTMeshLook>(object.entity);
}

SPTMeshLook SPTMeshLookGet(SPTObject object) {
    return spt::Scene::getRegistry(object).get<SPTMeshLook>(object.entity);
}

const SPTMeshLook* _Nullable SPTMeshLookTryGet(SPTObject object) {
    return spt::Scene::getRegistry(object).try_get<SPTMeshLook>(object.entity);
}

bool SPTMeshLookExists(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    return registry.all_of<SPTMeshLook>(object.entity);
}
