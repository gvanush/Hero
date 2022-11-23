//
//  PlayableScene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#include "PlayableScene.hpp"
#include "PlayableScene.h"
#include "Scene.hpp"
#include "MeshLook.h"
#include "MeshLook.hpp"
#include "RenderableMaterials.h"
#include "Position.hpp"
#include "Scale.hpp"
#include "Orientation.hpp"
#include "Camera.hpp"
#include "AnimatorManager.hpp"
#include "ObjectPropertyAnimatorBinding.hpp"

#include <entt/entt.hpp>


namespace spt {

PlayableScene::PlayableScene(const Scene& scene, const SPTPlayableSceneDescriptor& descriptor)
: _transformationGroup {registry.group<Transformation::AnimatorRecord, Transformation>()} {
    
    cloneEntities(scene, descriptor);
    
    // Prepare animators
    std::unordered_map<SPTAnimatorId, size_t> animatorIdToValueIndex;
    const auto& animatorManager = spt::AnimatorManager::active();
    
    if(descriptor.animatorsSize > 0) {
        _animatorIds = std::vector<SPTAnimatorId>{descriptor.animatorIds, descriptor.animatorIds + descriptor.animatorsSize};
    } else {
        const auto& span = animatorManager.animatorIds();
        _animatorIds = std::vector<SPTAnimatorId>{span.begin(), span.end()};
    }
    
    for(size_t i = 0; i < _animatorIds.size(); ++i) {
        animatorIdToValueIndex[_animatorIds[i]] = i + 1;
    }
    _animatorValues.assign(_animatorIds.size() + 1, 0.f);
    
    prepareTransformationAnimations(scene, animatorIdToValueIndex);
    
    prepareMeshLookAnimations(scene, animatorIdToValueIndex);
}

void PlayableScene::evaluateAnimators(const SPTAnimatorEvaluationContext& context) {
    size_t i = 1;
    for(auto& animatorId: _animatorIds) {
        _animatorValues[i++] = spt::AnimatorManager::active().evaluate(animatorId, context);
    }
}

void PlayableScene::update() {
    Transformation::updateWithOnlyAnimatorsChanging(registry, _transformationGroup, _animatorValues);
    MeshLook::updateWithOnlyAnimatorsChanging(registry, _animatorValues);
}

void PlayableScene::cloneEntities(const Scene& scene, const SPTPlayableSceneDescriptor& descriptor) {
    
    // Clone entities
    registry.assign(scene.registry.data(), scene.registry.data() + scene.registry.size(), scene.registry.released());
    
    // Clone transformations
    auto sourceTransView = scene.registry.view<spt::Transformation>();
    if(!sourceTransView.empty()) {
        registry.insert<spt::Transformation>(sourceTransView.data(), sourceTransView.data() + sourceTransView.size(), *sourceTransView.raw());
    }
    
    // Clone positions
    auto sourcePositionView = scene.registry.view<SPTPosition>();
    if(!sourcePositionView.empty()) {
        registry.insert<SPTPosition>(sourcePositionView.data(), sourcePositionView.data() + sourcePositionView.size(), *sourcePositionView.raw());
    }
    
    // Clone orientations
    auto sourceOrientationView = scene.registry.view<SPTOrientation>();
    if(!sourceOrientationView.empty()) {
        registry.insert<SPTOrientation>(sourceOrientationView.data(), sourceOrientationView.data() + sourceOrientationView.size(), *sourceOrientationView.raw());
    }
    
    // Clone scales
    auto sourceScaleView = scene.registry.view<SPTScale>();
    if(!sourceScaleView.empty()) {
        registry.insert<SPTScale>(sourceScaleView.data(), sourceScaleView.data() + sourceScaleView.size(), *sourceScaleView.raw());
    }
    
    // Clone mesh looks
    auto sourceMeshLooks = scene.registry.view<SPTMeshLook>();
    if(!sourceMeshLooks.empty()) {
        registry.insert<SPTMeshLook>(sourceMeshLooks.data(), sourceMeshLooks.data() + sourceMeshLooks.size(), *sourceMeshLooks.raw());
    }
    
    // Clone renderable materials
    auto sourcePhongRenderableMaterial = scene.registry.view<PhongRenderableMaterial>();
    if(!sourcePhongRenderableMaterial.empty()) {
        registry.insert<PhongRenderableMaterial>(sourcePhongRenderableMaterial.data(), sourcePhongRenderableMaterial.data() + sourcePhongRenderableMaterial.size(), *sourcePhongRenderableMaterial.raw());
    }

    auto sourcePlainColorRenderableMaterial = scene.registry.view<PlainColorRenderableMaterial>();
    if(!sourcePlainColorRenderableMaterial.empty()) {
        registry.insert<PlainColorRenderableMaterial>(sourcePlainColorRenderableMaterial.data(), sourcePlainColorRenderableMaterial.data() + sourcePlainColorRenderableMaterial.size(), *sourcePlainColorRenderableMaterial.raw());
    }
    
    // Clone camera
    registry.emplace<SPTPerspectiveCamera>(descriptor.viewCameraEntity, scene.registry.get<SPTPerspectiveCamera>(descriptor.viewCameraEntity));
    registry.emplace<spt::ProjectionMatrix>(descriptor.viewCameraEntity, scene.registry.get<spt::ProjectionMatrix>(descriptor.viewCameraEntity));
    params.viewCameraEntity = descriptor.viewCameraEntity;
    
}

void PlayableScene::prepareTransformationAnimations(const Scene& scene, const std::unordered_map<SPTAnimatorId, size_t>& animatorIdToValueIndex) {
    
    // Prepare transformation animators
    std::unordered_map<SPTEntity, spt::Transformation::AnimatorRecord> transformAnimatedEntityRecord;
    
    // Prepare position animators
    auto positionXAnimatorBindingView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyPositionX>>();
    positionXAnimatorBindingView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionX = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto positionYAnimatorBindingView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyPositionY>>();
    positionYAnimatorBindingView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionY = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto positionZAnimatorBindingView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyPositionZ>>();
    positionZAnimatorBindingView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionZ = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    for(auto& item: transformAnimatedEntityRecord) {
        item.second.basePosition = Position::getCartesianCoordinates(registry, item.first);
        item.second.baseScale = Scale::getXYZ(registry, item.first);
        item.second.baseOrientation = Orientation::getMatrix(registry, item.first, item.second.basePosition);
        registry.emplace<spt::Transformation::AnimatorRecord>(item.first, item.second);
    }
    
    // Sort once because parent child relationships are not going to change
    _transformationGroup.sort<Transformation>([] (const auto& lhs, const auto& rhs) {
        return lhs.node.level < rhs.node.level;
    });
    
}

void PlayableScene::prepareMeshLookAnimations(const Scene& scene, const std::unordered_map<SPTAnimatorId, size_t>& animatorIdToValueIndex) {
    
    // HSB
    std::unordered_map<SPTEntity, HSBColorAnimatorAnimatorRecord> hsbAnimatedEntityRecord;
    
    forEachHSBChannelBinding<SPTAnimatableObjectPropertyHue>(scene, animatorIdToValueIndex, [&hsbAnimatedEntityRecord] (auto entity, const auto& item) {
        hsbAnimatedEntityRecord[entity].hueItem = item;
    });
    
    forEachHSBChannelBinding<SPTAnimatableObjectPropertySaturation>(scene, animatorIdToValueIndex, [&hsbAnimatedEntityRecord] (auto entity, const auto& item) {
        hsbAnimatedEntityRecord[entity].saturationItem = item;
    });
    
    forEachHSBChannelBinding<SPTAnimatableObjectPropertyBrightness>(scene, animatorIdToValueIndex, [&hsbAnimatedEntityRecord] (auto entity, const auto& item) {
        hsbAnimatedEntityRecord[entity].brightnessItem = item;
    });
    
    for(auto& item: hsbAnimatedEntityRecord) {
        registry.emplace<HSBColorAnimatorAnimatorRecord>(item.first, item.second);
    }
    
    // RGB
    prepareRGBChannelAnimation<SPTAnimatableObjectPropertyRed>(scene, animatorIdToValueIndex);
    prepareRGBChannelAnimation<SPTAnimatableObjectPropertyGreen>(scene, animatorIdToValueIndex);
    prepareRGBChannelAnimation<SPTAnimatableObjectPropertyBlue>(scene, animatorIdToValueIndex);
    
    // Shininess
    auto shininessView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyShininess>, SPTMeshLook>();
    shininessView.each([this, &animatorIdToValueIndex] (auto entity, const auto& binding, const auto& look) {
        if(look.shading.type == SPTMeshShadingTypeBlinnPhong) {
            if(auto it = animatorIdToValueIndex.find(binding.base.animatorId); it != animatorIdToValueIndex.end()) {
                registry.emplace<spt::AnimatorBindingItem<SPTAnimatableObjectPropertyShininess>>(entity, AnimatorBindingItemBase {binding.base, it->second});
            }
        }
    });
    
}

template <SPTAnimatableObjectProperty P>
void PlayableScene::prepareRGBChannelAnimation(const Scene& scene,  const std::unordered_map<SPTAnimatorId, size_t>& animatorIdToValueIndex) {
    
    auto view = scene.registry.view<spt::AnimatorBinding<P>, SPTMeshLook>();
    view.each([this, &animatorIdToValueIndex] (auto entity, const auto& binding, const auto& look) {
        switch(look.shading.type) {
            case SPTMeshShadingTypeBlinnPhong: {
                if(look.shading.blinnPhong.color.model != SPTColorModelRGB) {
                    return;
                }
                break;
            }
            case SPTMeshShadingTypePlainColor: {
                if(look.shading.plainColor.color.model != SPTColorModelRGB) {
                    return;
                }
                break;
            }
        }
        
        if(auto it = animatorIdToValueIndex.find(binding.base.animatorId); it != animatorIdToValueIndex.end()) {
            registry.emplace<spt::AnimatorBindingItem<P>>(entity, AnimatorBindingItemBase {binding.base, it->second});
        }
    });
    
}

template <SPTAnimatableObjectProperty P>
void PlayableScene::forEachHSBChannelBinding(const Scene& scene,  const std::unordered_map<SPTAnimatorId, size_t>& animatorIdToValueIndex, const std::function<void (SPTEntity, const AnimatorBindingItemBase&)>& action) {
    
    auto view = scene.registry.view<spt::AnimatorBinding<P>, SPTMeshLook>();
    view.each([this, &animatorIdToValueIndex, &action] (auto entity, const auto& binding, const auto& look) {
        switch(look.shading.type) {
            case SPTMeshShadingTypeBlinnPhong: {
                if(look.shading.blinnPhong.color.model != SPTColorModelHSB) {
                    return;
                }
                break;
            }
            case SPTMeshShadingTypePlainColor: {
                if(look.shading.plainColor.color.model != SPTColorModelHSB) {
                    return;
                }
                break;
            }
        }
        
        if(auto it = animatorIdToValueIndex.find(binding.base.animatorId); it != animatorIdToValueIndex.end()) {
            action(entity, AnimatorBindingItemBase{ binding.base, it->second });
        }
    });
}

}

SPTHandle SPTPlayableSceneMake(SPTHandle sceneHandle, SPTPlayableSceneDescriptor descriptor) {
    
    auto scene = static_cast<spt::Scene*>(sceneHandle);
    scene->update();
    
    return new spt::PlayableScene(*scene, descriptor);
}

void SPTPlayableSceneDestroy(SPTHandle sceneHandle) {
    delete static_cast<spt::PlayableScene*>(sceneHandle);
}

SPTPlayableSceneParams SPTPlayableSceneGetParams(SPTHandle sceneHandle) {
    return static_cast<spt::PlayableScene*>(sceneHandle)->params;
}
