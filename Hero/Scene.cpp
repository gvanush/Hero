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
#include <iostream>

namespace hero {

namespace {

apple::metal::DepthStencilStateRef __depthStencilState;

}

Scene::Scene() {
    
}

void Scene::addSceneObject(SceneObject* sceneObject) {
    _sceneObjects.push_back(sceneObject);
}

SceneObject* Scene::raycast() const {
    if(_sceneObjects.empty()) {
        return  nullptr;
    }
    static size_t index = 0;
    return _sceneObjects[(index++) % _sceneObjects.size()];
}

void Scene::render(RenderingContext& renderingContext, const std::function<void ()>& onComplete) {
    assert(_viewCamera);
    
    using namespace apple;
    using namespace apple::metal;

    auto commandBufferRef = RenderingContext::commandQueue.newCommandBuffer();
    assert(commandBufferRef);
    commandBufferRef.setLabel(String::createWithUTF8String(u8"CommandBuffer"));
    
    auto commandEncoderRef = commandBufferRef.newRenderCommandEncoder(renderingContext.renderPassDescriptor);
    assert(commandEncoderRef);
    commandEncoderRef.setLabel(String::createWithUTF8String(u8"SceneRenderCommandEncoder"));
    
    commandEncoderRef.setDepthStencilState(__depthStencilState);
    
    renderingContext.commandBuffer = commandBufferRef;
    renderingContext.renderCommandEncoder = commandEncoderRef;
    renderingContext.uniforms.projectionViewMatrix = _viewCamera->projectionViewMatrix();
    
    Line::render(renderingContext);
    Layer::render(renderingContext);
    
    commandEncoderRef.endEncoding();
    
    commandBufferRef.addCompletedHandler([onComplete] (CommandBufferRef cmdBufRef) {
        // TODO: Error handling
        onComplete();
    });
    
    commandBufferRef.commit();
    
    commandBufferRef.present(renderingContext.drawable);
}

void Scene::setup() {
    Line::setup();
    Layer::setup();
    
    apple::metal::DepthStencilDescriptorRef descr = apple::metal::DepthStencilDescriptor::create();
    descr.setDepthWriteEnabled(true);
    descr.setDepthCompareFunction(apple::metal::CompareFunction::less);
    __depthStencilState = RenderingContext::device.newDepthStencilState(descr);
}

}
