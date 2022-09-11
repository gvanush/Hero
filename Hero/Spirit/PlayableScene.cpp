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
    const auto& sourceRegistry = scene->registry;
    auto view = sourceRegistry.view<SPTMeshLook, spt::Transformation>();
    
    auto playableScene = new spt::PlayableScene{};
    auto& registry = playableScene->registry;
    
    view.each([&registry] (auto entity, auto& meshLook, auto& transformation) {
        auto newEntity = registry.create();
        registry.emplace<SPTMeshLook>(newEntity, meshLook);
        registry.emplace<spt::Transformation>(newEntity, transformation);
    });
    
    
    
//    registry.assign(sourceRegistry.data(), sourceRegistry.data() + sourceRegistry.size(), sourceRegistry.released());
    
//    auto meshLookView = sourceRegistry.view<SPTMeshLook>();
////    const SPTMeshLook* meshLookArray = meshLookView.raw();
//    registry.insert(meshLookView.data(), meshLookView.data() + meshLookView.size(), *meshLookView.raw());
//
//    auto transformationView = sourceRegistry.view<spt::Transformation>();
//    registry.insert(transformationView.data(), transformationView.data() + transformationView.size(), *transformationView.raw());
//
//    auto view = registry.view<spt::Transformation>();
//    assert(!view.empty());
    auto cameraEntity = registry.create();
    registry.emplace<SPTPerspectiveCamera>(cameraEntity, sourceRegistry.get<SPTPerspectiveCamera>(descriptor.viewCameraEntity));
    registry.emplace<spt::ProjectionMatrix>(cameraEntity, sourceRegistry.get<spt::ProjectionMatrix>(descriptor.viewCameraEntity));
    registry.emplace<spt::Transformation>(cameraEntity, sourceRegistry.get<spt::Transformation>(descriptor.viewCameraEntity));
    registry.emplace<SPTPosition>(cameraEntity, sourceRegistry.get<SPTPosition>(descriptor.viewCameraEntity));
    playableScene->params.viewCameraEntity = cameraEntity;
    
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
