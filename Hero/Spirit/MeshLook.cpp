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
#include "ObjectPropertyAnimatorBinding.hpp"


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

template <SPTAnimatableObjectProperty P>
void updateRGBAChannel(spt::Registry& registry, const std::vector<float> animatorValues, size_t channelIndex) {
    
    auto view = registry.view<spt::AnimatorBindingItem<P>, SPTMeshLook>();
    view.each([&registry, &animatorValues, channelIndex] (auto entity, const auto& item, const auto& look) {
        
        const auto value = spt::evaluateAnimatorBinding(item.base.binding, animatorValues[item.base.index]);
        
        switch (look.shading.type) {
            case SPTMeshShadingTypePlainColor: {
                registry.get<spt::PlainColorRenderableMaterial>(entity).color[channelIndex] = value;
                break;
            }
            case SPTMeshShadingTypeBlinnPhong: {
                registry.get<spt::PhongRenderableMaterial>(entity).color[channelIndex] = value;
                break;
            }
        }
        
    });
    
}

}

bool SPTMeshShadingValidate(SPTMeshShading shading) {
    switch (shading.type) {
        case SPTMeshShadingTypePlainColor: {
            return SPTColorValidate(shading.plainColor.color);
        }
        case SPTMeshShadingTypeBlinnPhong: {
            return shading.blinnPhong.shininess >= 0.f && shading.blinnPhong.shininess <= 1.f && SPTColorValidate(shading.blinnPhong.color);
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
    registry.emplace<SPTMeshLook>(object.entity, meshLook);
    addRenderableMaterial(meshLook.shading.type, registry, object.entity);
    spt::emplaceIfMissing<spt::DirtyRenderableMaterialFlag>(registry, object.entity);
    spt::notifyComponentDidEmergeObservers(registry, object.entity, meshLook);
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

SPTObserverToken SPTMeshLookAddDidEmergeObserver(SPTObject object, SPTMeshLookDidEmergeObserver observer, SPTObserverUserInfo userInfo) {
    return spt::addComponentDidEmergeObserver<SPTMeshLook>(object, observer, userInfo);
}

void SPTMeshLookRemoveDidEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentDidEmergeObserver<SPTMeshLook>(object, token);
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
                renderableMaterial.shininess = meshLook.shading.blinnPhong.shininess;
                
                break;
            }
        }
        
    });
    
    registry.clear<DirtyRenderableMaterialFlag>();
}

void MeshLook::updateWithOnlyAnimatorsChanging(spt::Registry& registry, const std::vector<float>& animatorValues) {
    
    auto hsbView = registry.view<spt::HSBColorAnimatorAnimatorRecord, SPTMeshLook>();
    hsbView.each([&registry, &animatorValues] (auto entity, const auto& record, const auto& look) {
        
        SPTColor color;
        
        switch (look.shading.type) {
            case SPTMeshShadingTypePlainColor: {
                color = look.shading.plainColor.color;
                break;
            }
            case SPTMeshShadingTypeBlinnPhong: {
                color = look.shading.blinnPhong.color;
                break;
            }
        }
        
        if(record.hueItem.index != 0) {
            color.hsba.hue = evaluateAnimatorBinding(record.hueItem.binding, animatorValues[record.hueItem.index]);
        }

        if(record.saturationItem.index != 0) {
            color.hsba.saturation = evaluateAnimatorBinding(record.saturationItem.binding, animatorValues[record.saturationItem.index]);
        }

        if(record.brightnessItem.index != 0) {
            color.hsba.brightness = evaluateAnimatorBinding(record.brightnessItem.binding, animatorValues[record.brightnessItem.index]);
        }
        
        switch (look.shading.type) {
            case SPTMeshShadingTypePlainColor: {
                registry.get<PlainColorRenderableMaterial>(entity).color = SPTColorToRGBA(color).rgba.float4;
                break;
            }
            case SPTMeshShadingTypeBlinnPhong: {
                registry.get<PhongRenderableMaterial>(entity).color = SPTColorToRGBA(color).rgba.float4;
                break;
            }
        }
        
    });
    
    updateRGBAChannel<SPTAnimatableObjectPropertyRed>(registry, animatorValues, 0);
    updateRGBAChannel<SPTAnimatableObjectPropertyGreen>(registry, animatorValues, 0);
    updateRGBAChannel<SPTAnimatableObjectPropertyBlue>(registry, animatorValues, 0);
    
    auto shininessView = registry.view<spt::AnimatorBindingItem<SPTAnimatableObjectPropertyShininess>, SPTMeshLook>();
    shininessView.each([&registry, &animatorValues] (auto entity, const auto& item, const auto& look) {
        const auto value = spt::evaluateAnimatorBinding(item.base.binding, animatorValues[item.base.index]);
        registry.get<spt::PhongRenderableMaterial>(entity).shininess = value;
    });
    
}

void MeshLook::onDestroy(spt::Registry& registry, SPTEntity entity) {
    removeRenderableMaterial(registry.get<SPTMeshLook>(entity).shading.type, registry, entity);
    registry.remove<spt::DirtyRenderableMaterialFlag>(entity);
}

}
