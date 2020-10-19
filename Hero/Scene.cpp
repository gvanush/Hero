//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#include "Scene.hpp"
#include "RenderingContext.hpp"
#include "Camera.hpp"
#include "Line.hpp"
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
    
    auto commandEncoderRef = commandBufferRef.newRenderCommandEncoder(renderingContext.renderPassDescriptor);
    assert(commandEncoderRef);
    commandEncoderRef.setLabel(String::createWithUTF8String(u8"SceneRenderCommandEncoder"));
    
    renderingContext.commandBuffer = commandBufferRef;
    renderingContext.renderCommandEncoder = commandEncoderRef;
    renderingContext.uniforms.projectionViewMatrix = _viewCamera->projectionViewMatrix();
    
    Line::render(renderingContext);
    Layer::render(renderingContext);
    
    commandEncoderRef.endEncoding();
    
    commandBufferRef.present(renderingContext.drawable);
    
    commandBufferRef.commit();
    
}

void Scene::setup() {
    Line::setup();
    Layer::setup();
}

}
