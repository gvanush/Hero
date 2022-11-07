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
#include "ComponentObserverUtil.hpp"


namespace {

void addRenderableMaterial(SPTMeshShadingType shadingType, spt::Registry& registry, SPTEntity entity) {
    
    switch (shadingType) {
        case SPTMeshShadingTypePlainColor: {
            registry.emplace<spt::PlainColorRenderableMaterial>(entity);
            break;
        }
        case SPTMeshShadingTypeBlinnPhong: {
            registry.emplace<spt::PhongRenderableMaterial>(entity);
            break;
        }
    }
    
}

void removeRenderableMaterial(SPTMeshShadingType shadingType, spt::Registry& registry, SPTEntity entity) {
    
    switch (shadingType) {
        case SPTMeshShadingTypePlainColor: {
            registry.erase<spt::PlainColorRenderableMaterial>(entity);
            break;
        }
        case SPTMeshShadingTypeBlinnPhong: {
            registry.erase<spt::PhongRenderableMaterial>(entity);
            break;
        }
    }
    
}

}

bool SPTMeshShadingValidate(SPTMeshShading shading) {
    switch (shading.type) {
        case SPTMeshShadingTypePlainColor: {
            return SPTColorValidate(shading.plainColor.color);
        }
        case SPTMeshShadingTypeBlinnPhong: {
            // TODO: Add specular roughness
            return SPTColorValidate(shading.blinnPhong.color);
        }
    }
}

bool SPTMeshShadingEqual(SPTMeshShading lhs, SPTMeshShading rhs) {
    if(lhs.type != rhs.type) {
        return false;
    }
    switch (lhs.type) {
        case SPTMeshShadingTypePlainColor: {
            return SPTPlainColorMaterialEqual(lhs.plainColor, rhs.plainColor);
        }
        case SPTMeshShadingTypeBlinnPhong: {
            return SPTPhongMaterialEqual(lhs.blinnPhong, rhs.blinnPhong);
        }
    }
}

bool SPTMeshLookEqual(SPTMeshLook lhs, SPTMeshLook rhs) {
    return SPTMeshShadingEqual(lhs.shading, rhs.shading) && lhs.meshId == rhs.meshId && lhs.categories == rhs.categories;
}

void SPTMeshLookMake(SPTObject object, SPTMeshLook meshLook) {
    assert(SPTMeshShadingValidate(meshLook.shading));
    
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillEmergeObservers(registry, object.entity, meshLook);
    registry.emplace<SPTMeshLook>(object.entity, meshLook);
    addRenderableMaterial(meshLook.shading.type, registry, object.entity);
    spt::emplaceIfMissing<spt::DirtyRenderableMaterialFlag>(registry, object.entity);
}

void SPTMeshLookUpdate(SPTObject object, SPTMeshLook updated) {
    assert(SPTMeshShadingValidate(updated.shading));
    
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillChangeObservers(registry, object.entity, updated);
    auto& meshLook = registry.get<SPTMeshLook>(object.entity);
    if(!SPTMeshShadingEqual(meshLook.shading, updated.shading)) {
        spt::emplaceIfMissing<spt::DirtyRenderableMaterialFlag>(registry, object.entity);
        if(meshLook.shading.type != updated.shading.type) {
            removeRenderableMaterial(meshLook.shading.type, registry, object.entity);
            addRenderableMaterial(updated.shading.type, registry, object.entity);
        }
    }
    meshLook = updated;
}

void SPTMeshLookDestroy(SPTObject object) {
    auto& registry = spt::Scene::getRegistry(object);
    spt::notifyComponentWillPerishObservers<SPTMeshLook>(registry, object.entity);
    registry.erase<SPTMeshLook>(object.entity);
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

SPTObserverToken SPTMeshLookAddWillChangeObserver(SPTObject object, SPTMeshLookWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillChangeObserver<SPTMeshLook>(object, observer, userInfo);
}

void SPTMeshLookRemoveWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillChangeObserver<SPTMeshLook>(object, token);
}

SPTObserverToken SPTMeshLookAddWillEmergeObserver(SPTObject object, SPTMeshLookWillEmergeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillEmergeObserver<SPTMeshLook>(object, observer, userInfo);
}

void SPTMeshLookRemoveWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillEmergeObserver<SPTMeshLook>(object, token);
}

SPTObserverToken SPTMeshLookAddWillPerishObserver(SPTObject object, SPTMeshLookWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentWillPerishObserver<SPTMeshLook>(object, observer, userInfo);
}

void SPTMeshLookRemoveWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentWillPerishObserver<SPTMeshLook>(object, token);
}

namespace spt {

void MeshLook::update(spt::Registry& registry) {
    
    auto view = registry.view<DirtyRenderableMaterialFlag, SPTMeshLook>();
    view.each([&registry] (const auto entity, const SPTMeshLook& meshLook) {
        
        switch (meshLook.shading.type) {
            case SPTMeshShadingTypePlainColor: {
                
                auto& renderableMaterial = registry.get<PlainColorRenderableMaterial>(entity);
                renderableMaterial.color = SPTColorToRGBA(meshLook.shading.plainColor.color).rgba.float4;
                
                break;
            }
            case SPTMeshShadingTypeBlinnPhong: {
                
                auto& renderableMaterial = registry.get<PhongRenderableMaterial>(entity);
                renderableMaterial.color = SPTColorToRGBA(meshLook.shading.blinnPhong.color).rgba.float4;
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
