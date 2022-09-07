//
//  PlayableScene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

#include "PlayableScene.hpp"
#include "Scene.hpp"
#include "MeshLook.h"
#include "Transformation.hpp"
#include "Camera.hpp"

#include <entt/entt.hpp>

namespace spt {

void PlayableScene::setupFromScene(const Scene* scene, SPTEntity viewCameraEntity) {
    
    const auto& sourceRegistry = scene->registry;
    auto view = sourceRegistry.view<SPTMeshLook, spt::Transformation>();
    view.each([this] (auto entity, auto& meshLook, auto& transformation) {
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
    this->viewCameraEntity = cameraEntity;
    
    assert(sourceRegistry.all_of<spt::Transformation>(viewCameraEntity));
    assert(registry.all_of<spt::Transformation>(this->viewCameraEntity));
}

void PlayableScene::render(void* renderingContext) {
    renderer.render(renderingContext);
}

}
