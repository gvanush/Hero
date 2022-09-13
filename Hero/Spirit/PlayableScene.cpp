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
    registry.insert<spt::Transformation>(sourceTransView.data(), sourceTransView.data() + sourceTransView.size(), *sourceTransView.raw());
    
    // Clone positions
    auto sourcePositionView = scene.registry.view<SPTPosition>();
    registry.insert<SPTPosition>(sourcePositionView.data(), sourcePositionView.data() + sourcePositionView.size(), *sourcePositionView.raw());
    
    // Clone orientations
    auto sourceOrientationView = scene.registry.view<SPTOrientation>();
    registry.insert<SPTOrientation>(sourceOrientationView.data(), sourceOrientationView.data() + sourceOrientationView.size(), *sourceOrientationView.raw());
    
    // Clone scales
    auto sourceScaleView = scene.registry.view<SPTScale>();
    registry.insert<SPTScale>(sourceScaleView.data(), sourceScaleView.data() + sourceScaleView.size(), *sourceScaleView.raw());
    
    // Clone mesh looks
    auto sourceMeshLookView = scene.registry.view<SPTMeshLook>();
    registry.insert<SPTMeshLook>(sourceMeshLookView.data(), sourceMeshLookView.data() + sourceMeshLookView.size(), *sourceMeshLookView.raw());
    
    // Clone camera
    registry.emplace<SPTPerspectiveCamera>(descriptor.viewCameraEntity, scene.registry.get<SPTPerspectiveCamera>(descriptor.viewCameraEntity));
    registry.emplace<spt::ProjectionMatrix>(descriptor.viewCameraEntity, scene.registry.get<spt::ProjectionMatrix>(descriptor.viewCameraEntity));
    params.viewCameraEntity = descriptor.viewCameraEntity;
    
    // Prepare animators
    std::unordered_map<SPTAnimatorId, size_t> animatorIdToValueIndex;
    const auto& animatorManager = spt::AnimatorManager::active();
    
    if(const auto activeAnimators = descriptor.animators) {
        _animators.reserve(descriptor.animatorsSize);
        for(size_t i = 0; i < descriptor.animatorsSize; ++i) {
            const auto& animator = animatorManager.getAnimator(activeAnimators[i]);
            _animators.emplace_back(animator);
            animatorIdToValueIndex[animator.id] = i + 1;
        }
        _animatorValues.assign(descriptor.animatorsSize + 1, 0.f);
    } else {
        _animators = animatorManager.animators();
        for(size_t i = 0; i < _animators.size(); ++i) {
            animatorIdToValueIndex[_animators[i].id] = i + 1;
        }
        _animatorValues.assign(_animators.size() + 1, 0.f);
    }
    
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
    for(auto& animator: _animators) {
        _animatorValues[i++] = spt::AnimatorManager::evaluate(animator, context);
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
