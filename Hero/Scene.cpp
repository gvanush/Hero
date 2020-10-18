//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#include "Scene.hpp"
#include "RenderingContext.hpp"
#include "Camera.hpp"
#include "Layer.hpp"

#include "apple/metal/Metal.h"

#include <array>

namespace hero {

Scene::Scene() {
    
}

void Scene::addSceneObject(SceneObject* sceneObject) {
    _sceneObjects.push_back(sceneObject);
}

void Scene::render(RenderingContext& renderingContext) {
    assert(_viewCamera);
    
    using namespace apple;
    using namespace apple::metal;

    auto commandBufferRef = RenderingContext::commandQueue.newCommandBuffer();
    assert(commandBufferRef);
    commandBufferRef.setLabel(String::createWithUTF8String(u8"CommandBuffer"));
    
    renderingContext.commandBuffer = commandBufferRef;
    renderingContext.uniforms.projectionViewMatrix = _viewCamera->projectionViewMatrix();
    
    Layer::render(renderingContext);
    
    commandBufferRef.present(renderingContext.drawable);
    
    commandBufferRef.commit();
    
}

void Scene::setup() {
    Layer::setup();
}

}
