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
    
    // Prepare transformation animators
    std::unordered_map<SPTEntity, spt::Transformation::AnimatorRecord> transformAnimatedEntityRecord;
    
    // Prepare position animators
    auto positionXAnimatorBindingView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyPositionX>>();
    positionXAnimatorBindingView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionX = AnimatorBindingItem{ comp.base, it->second };
        }
    });
    
    auto positionYAnimatorBindingView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyPositionY>>();
    positionYAnimatorBindingView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionY = AnimatorBindingItem{ comp.base, it->second };
        }
    });
    
    auto positionZAnimatorBindingView = scene.registry.view<spt::AnimatorBinding<SPTAnimatableObjectPropertyPositionZ>>();
    positionZAnimatorBindingView.each([&animatorIdToValueIndex, &transformAnimatedEntityRecord] (auto entity, const auto& comp) {
        if(auto it = animatorIdToValueIndex.find(comp.base.animatorId); it != animatorIdToValueIndex.end()) {
            transformAnimatedEntityRecord[entity].positionZ = AnimatorBindingItem{ comp.base, it->second };
        }
    });
    
    for(auto& item: transformAnimatedEntityRecord) {
        item.second.basePosition = Position::getXYZ(registry, item.first);
        item.second.baseScale = Scale::getXYZ(registry, item.first);
        item.second.baseOrientation = Orientation::getMatrix(registry, item.first, item.second.basePosition);
        registry.emplace<spt::Transformation::AnimatorRecord>(item.first, item.second);
    }
    
    // Sort once because parent child relationships are not going to change
    _transformationGroup.sort<Transformation>([] (const auto& lhs, const auto& rhs) {
        return lhs.node.level < rhs.node.level;
    });
    
}

void PlayableScene::evaluateAnimators(const SPTAnimatorEvaluationContext& context) {
    size_t i = 1;
    for(auto& animatorId: _animatorIds) {
        _animatorValues[i++] = spt::AnimatorManager::active().evaluate(animatorId, context);
    }
}

void PlayableScene::update() {
    Transformation::updateWithOnlyAnimatorsChanging(registry, _transformationGroup, _animatorValues);
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
