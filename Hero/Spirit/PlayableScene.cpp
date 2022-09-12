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
#include "Position.h"
#include "Transformation.hpp"
#include "Camera.hpp"
#include "AnimatorManager.hpp"

#include <entt/entt.hpp>


namespace spt {

void PlayableScene::render(void* renderingContext) {
    renderer.render(renderingContext);
}

void PlayableScene::evaluateAnimators(const SPTAnimatorEvaluationContext& context) {
    for(auto& item: animatorItems) {
        item.value = spt::AnimatorManager::evaluate(item.animator, context);
    }
}

}

SPTHandle SPTPlayableSceneMake(SPTHandle sceneHandle, SPTPlayableSceneDescriptor descriptor) {
    
    auto scene = static_cast<spt::Scene*>(sceneHandle);
    
    // Update global matrices
    spt::Transformation::update(scene->registry, scene->transformationGroup);
    
    const auto& sourceRegistry = scene->registry;
    
    auto playableScene = new spt::PlayableScene{};
    auto& registry = playableScene->registry;
    
    // Clone entities
    registry.assign(sourceRegistry.data(), sourceRegistry.data() + sourceRegistry.size(), sourceRegistry.released());
    
    // Clone transformations
    auto sourceTransView = sourceRegistry.view<spt::Transformation>();
    registry.insert<spt::Transformation>(sourceTransView.data(), sourceTransView.data() + sourceTransView.size(), *sourceTransView.raw());
    
    // Clone mesh looks
    auto sourceMeshLookView = sourceRegistry.view<SPTMeshLook>();
    registry.insert<SPTMeshLook>(sourceMeshLookView.data(), sourceMeshLookView.data() + sourceMeshLookView.size(), *sourceMeshLookView.raw());
    
    
//    auto transView = registry.view<spt::Transformation>();
//    transView.each([] (auto& trans) {
//        trans.node
//    });
    
    //
    
    // Clone camera
    registry.emplace<SPTPerspectiveCamera>(descriptor.viewCameraEntity, sourceRegistry.get<SPTPerspectiveCamera>(descriptor.viewCameraEntity));
    registry.emplace<spt::ProjectionMatrix>(descriptor.viewCameraEntity, sourceRegistry.get<spt::ProjectionMatrix>(descriptor.viewCameraEntity));
    registry.emplace<SPTPosition>(descriptor.viewCameraEntity, sourceRegistry.get<SPTPosition>(descriptor.viewCameraEntity));
    playableScene->params.viewCameraEntity = descriptor.viewCameraEntity;
    
    assert(sourceRegistry.all_of<spt::Transformation>(descriptor.viewCameraEntity));
    assert(registry.all_of<spt::Transformation>(playableScene->params.viewCameraEntity));
    
    // Prepare animators
    const auto& animatorManager = spt::AnimatorManager::active();
    if(const auto animators = descriptor.animators) {
        playableScene->animatorItems.reserve(descriptor.animatorsSize);
        for(auto it = animators; it != animators + descriptor.animatorsSize; ++it) {
            playableScene->animatorItems.emplace_back(spt::AnimatorItem {animatorManager.getAnimator(*it), 0.f});
        }
    } else {
        playableScene->animatorItems.reserve(animatorManager.animators().size());
        for(const auto& animator: animatorManager.animators()) {
            playableScene->animatorItems.emplace_back(spt::AnimatorItem {animator, 0.f});
        }
    }
    
    return playableScene;
}

void SPTPlayableSceneDestroy(SPTHandle sceneHandle) {
    delete static_cast<spt::PlayableScene*>(sceneHandle);
}

SPTPlayableSceneParams SPTPlayableSceneGetParams(SPTHandle sceneHandle) {
    return static_cast<spt::PlayableScene*>(sceneHandle)->params;
}
