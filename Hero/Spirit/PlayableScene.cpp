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
#include "Matrix.h"

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
    
    // Position
    
    // Cartesian
    auto cartesianXView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionX>>();
    cartesianXView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.cartesian.x = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto cartesianYView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionY>>();
    cartesianYView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.cartesian.y = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto cartesianZView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyCartesianPositionZ>>();
    cartesianZView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.cartesian.z = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    // Linear
    auto linearOffsetView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyLinearPositionOffset>>();
    linearOffsetView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.linear.offset = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    // Spherical
    auto sphericalRadiusView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertySphericalPositionRadius>>();
    sphericalRadiusView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.spherical.radius = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto sphericalLongitudeView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertySphericalPositionLongitude>>();
    sphericalLongitudeView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.spherical.longitude = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto sphericalLatitudeView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertySphericalPositionLatitude>>();
    sphericalLatitudeView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.spherical.latitude = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    // Cylindrical
    auto cylindricalRadiusView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionRadius>>();
    cylindricalRadiusView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.cylindrical.radius = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto cylindricalLongitudeView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionLongitude>>();
    cylindricalLongitudeView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.cylindrical.longitude = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto sphericalHeightView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyCylindricalPositionHeight>>();
    sphericalHeightView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionRecord.cylindrical.height = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    // Orientation
    
    // Euler
    
    auto eulerOrientationXView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationX>>();
    eulerOrientationXView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].orientationRecord.euler.x = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto eulerOrientationYView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationY>>();
    eulerOrientationYView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].orientationRecord.euler.y = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto eulerOrientationZView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyEulerOrientationZ>>();
    eulerOrientationZView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].orientationRecord.euler.z = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    // Scale
    
    // XYZ
    auto xyzScaleXView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyXYZScaleX>>();
    xyzScaleXView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].scaleRecord.xyz.x = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto xyzScaleYView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyXYZScaleY>>();
    xyzScaleYView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].scaleRecord.xyz.y = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    auto xyzScaleZView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyXYZScaleZ>>();
    xyzScaleZView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].scaleRecord.xyz.z = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
   
    auto uniformScaleXView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyUniformScale>>();
    uniformScaleXView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].scaleRecord.uniform = AnimatorBindingItemBase{ comp.base, it->second };
        }
    });
    
    for(auto& item: transformAnimatedEntityRecord) {
        item.second.basePosition = registry.get<SPTPosition>(item.first);
        item.second.baseScale = registry.get<SPTScale>(item.first);
        item.second.baseOrientation = registry.get<SPTOrientation>(item.first);
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
    scene->updateTransformations();
    scene->updateLooks();
    
    return new spt::PlayableScene(*scene, descriptor);
}

void SPTPlayableSceneDestroy(SPTHandle sceneHandle) {
    delete static_cast<spt::PlayableScene*>(sceneHandle);
}

SPTPlayableSceneParams SPTPlayableSceneGetParams(SPTHandle sceneHandle) {
    return static_cast<spt::PlayableScene*>(sceneHandle)->params;
}
