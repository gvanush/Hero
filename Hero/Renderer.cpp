//
//  Renderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 11/26/20.
//

#include "Renderer.hpp"
#include "BitwiseUtils.hpp"
#include "RenderingContext.hpp"
#include "Scene.hpp"
#include "Camera.hpp"
#include "LineRenderer.hpp"
#include "Layer.hpp"
#include "RemovedComponentRegistry.hpp"

#include "apple/metal/Metal.h"

namespace hero {

std::array<Renderer*, Renderer::kLimit> Renderer::_allRenderers {};

namespace {

apple::metal::DepthStencilStateRef __depthStencilState;

}

void Renderer::render(Scene& scene, RenderingContext& renderingContext) {
    assert(scene.viewCamera());
    
    auto stepNumber = scene.stepNumber();
    // TODO: delta time
    scene.step(0.f);
    
    // Clean rempved components
    // TODO
    
    // Update renderers
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
    renderingContext.uniforms.projectionViewMatrix = scene.viewCamera()->get<Camera>()->projectionViewMatrix();
    
    LineRenderer::render(renderingContext);
    Layer::render(renderingContext);
    
    commandEncoderRef.endEncoding();
    
    commandBufferRef.addCompletedHandler([stepNumber, &scene] (CommandBufferRef) {
        // TODO: 'scene' may not be alive at this point (maybe moving to ObjC/Swift layet with weak ref?)
        // TODO: check the thread of execution of this callback
        RemovedComponentRegistry::shared().destroyComponents(scene, stepNumber);
    });
    
    commandBufferRef.commit();
    
    // This guarantees that
    // 1. all command buffer work will be completed before the drawable is actually presented
    // 2. Core Animation transaction will be available at the time the drawable is presented
    commandBufferRef.waitUntilScheduled();
}

void Renderer::setup() {
    LineRenderer::setup();
    Layer::setup();
    
    apple::metal::DepthStencilDescriptorRef descr = apple::metal::DepthStencilDescriptor::create();
    descr.setDepthWriteEnabled(true);
    descr.setDepthCompareFunction(apple::metal::CompareFunction::less);
    __depthStencilState = RenderingContext::device.newDepthStencilState(descr);
}

Renderer* Renderer::make() {
    for (std::size_t i = 0; i < _allRenderers.size(); ++i) {
        if(_allRenderers[i]) {
            continue;
        }
        const RendererFlag flag = (0x1 << i);
        return _allRenderers[i] = new Renderer {flag};
    }
    
    return nullptr;
}

Renderer* Renderer::get(RendererFlag flag) {
    return _allRenderers[lastBitPosition(flag)];
}

const std::array<Renderer*, Renderer::kLimit>& Renderer::allRenderers() {
    return _allRenderers;
}

Renderer::~Renderer() {
    _allRenderers[lastBitPosition(_flag)] = nullptr;
}

Renderer::Renderer(RendererFlag flag)
: _flag(flag) {
}

}
