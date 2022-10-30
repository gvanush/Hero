//
//  MeshLook.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 18.11.21.
//

#include "MeshLook.h"
#include "MeshLook.hpp"
#include "Scene.hpp"
#include "RenderableMaterials.h"

namespace {

void addRenderableMaterial(SPTMeshShadingType shadingType, spt::Registry& registry, SPTEntity entity) {
    
    switch (shadingType) {
        case SPTMeshShadingPlainColor: {
            registry.emplace<spt::PlainColorRenderableMaterial>(entity);
            break;
        }
        case SPTMeshShadingBlinnPhong: {
            registry.emplace<spt::PhongRenderableMaterial>(entity);
            break;
        }
    }
    
}

void removeRenderableMaterial(SPTMeshShadingType shadingType, spt::Registry& registry, SPTEntity entity) {
    
    switch (shadingType) {
        case SPTMeshShadingPlainColor: {
            registry.erase<spt::PlainColorRenderableMaterial>(entity);
            break;
        }
        case SPTMeshShadingBlinnPhong: {
            registry.erase<spt::PhongRenderableMaterial>(entity);
            break;
        }
    }
    
}

}

bool SPTMeshLookEqual(SPTMeshLook lhs, SPTMeshLook rhs) {
    return SPTMeshShadingEqual(lhs.shading, rhs.shading) && lhs.meshId == rhs.meshId && lhs.categories == rhs.categories;
}

bool SPTMeshShadingEqual(SPTMeshShading lhs, SPTMeshShading rhs) {
    if(lhs.type != rhs.type) {
        return false;
    }
    switch (lhs.type) {
        case SPTMeshShadingPlainColor: {
            return SPTPlainColorMaterialEqual(lhs.plainColor, rhs.plainColor);
        }
        case SPTMeshShadingBlinnPhong: {
            return SPTPhongMaterialEqual(lhs.blinnPhong, rhs.blinnPhong);
        }
    }
}

void SPTMeshLookMake(SPTObject object, SPTMeshLook meshLook) {
    auto& registry = spt::Scene::getRegistry(object);
    registry.emplace<SPTMeshLook>(object.entity, meshLook);
    addRenderableMaterial(meshLook.shading.type, registry, object.entity);
    spt::emplaceIfMissing<spt::DirtyRenderableMaterialFlag>(registry, object.entity);
}

void SPTMeshLookUpdate(SPTObject object, SPTMeshLook updated) {
    auto& registry = spt::Scene::getRegistry(object);
    auto& meshLook = registry.get<SPTMeshLook>(object.entity);
    if(SPTMeshShadingEqual(meshLook.shading, updated.shading)) {
        spt::emplaceIfMissing<spt::DirtyRenderableMaterialFlag>(registry, object.entity);
        if(meshLook.shading.type != updated.shading.type) {
            removeRenderableMaterial(meshLook.shading.type, registry, object.entity);
            addRenderableMaterial(updated.shading.type, registry, object.entity);
        }
    }
    meshLook = updated;
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

namespace spt {

void MeshLook::update(spt::Registry& registry) {
    
    auto view = registry.view<DirtyRenderableMaterialFlag, SPTMeshLook>();
    view.each([&registry] (const auto entity, const SPTMeshLook& meshLook) {
        
        switch (meshLook.shading.type) {
            case SPTMeshShadingPlainColor: {
                
                auto& renderableMaterial = registry.get<PlainColorRenderableMaterial>(entity);
                renderableMaterial.color = meshLook.shading.plainColor.color;
                
                break;
            }
            case SPTMeshShadingBlinnPhong: {
                
                auto& renderableMaterial = registry.get<PhongRenderableMaterial>(entity);
                renderableMaterial.color = meshLook.shading.blinnPhong.color;
                renderableMaterial.specularRoughness = meshLook.shading.blinnPhong.specularRoughness;
                
                break;
            }
        }
        
    });
    
    registry.clear<DirtyRenderableMaterialFlag>();
}

void MeshLook::onDestroy(spt::Registry& registry, SPTEntity entity) {
    removeRenderableMaterial(registry.get<SPTMeshLook>(entity).shading.type, registry, entity);
    registry.remove<spt::DirtyRenderableMaterialFlag>(entity);
}

}
