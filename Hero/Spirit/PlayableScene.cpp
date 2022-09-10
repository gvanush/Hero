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
#include "Transformation.hpp"
#include "Camera.hpp"

#include <entt/entt.hpp>

namespace spt {

void PlayableScene::render(void* renderingContext) {
    renderer.render(renderingContext);
}

}

SPTHandle SPTPlayableSceneMake(SPTHandle sceneHandle, SPTEntity viewCameraEntity) {
    
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
    registry.emplace<SPTPerspectiveCamera>(cameraEntity, sourceRegistry.get<SPTPerspectiveCamera>(viewCameraEntity));
    registry.emplace<spt::ProjectionMatrix>(cameraEntity, sourceRegistry.get<spt::ProjectionMatrix>(viewCameraEntity));
    registry.emplace<spt::Transformation>(cameraEntity, sourceRegistry.get<spt::Transformation>(viewCameraEntity));
    playableScene->params.viewCameraEntity = cameraEntity;
    
    assert(sourceRegistry.all_of<spt::Transformation>(viewCameraEntity));
    assert(registry.all_of<spt::Transformation>(playableScene->params.viewCameraEntity));
    
    return playableScene;
}

void SPTPlayableSceneDestroy(SPTHandle sceneHandle) {
    delete static_cast<spt::PlayableScene*>(sceneHandle);
}

SPTPlayableSceneParams SPTPlayableSceneGetParams(SPTHandle sceneHandle) {
    return static_cast<spt::PlayableScene*>(sceneHandle)->params;
}
