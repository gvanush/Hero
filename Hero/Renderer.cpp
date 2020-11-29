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
#include "Line.hpp"
#include "Layer.hpp"

#include "apple/metal/Metal.h"

namespace hero {

std::array<Renderer*, Renderer::kLimit> Renderer::_allRenderers {};

namespace {

apple::metal::DepthStencilStateRef __depthStencilState;

}

void Renderer::render(const Scene& scene, RenderingContext& renderingContext, const std::function<void ()>& onComplete) {
    assert(scene.viewCamera());
    
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
    renderingContext.uniforms.projectionViewMatrix = scene.viewCamera()->projectionViewMatrix();
    
    Line::render(renderingContext);
    Layer::render(renderingContext);
    
    commandEncoderRef.endEncoding();
    
    if(onComplete) {
        commandBufferRef.addCompletedHandler([onComplete] (CommandBufferRef cmdBufRef) {
            // TODO: Error handling
            onComplete();
        });
    }
    
    commandBufferRef.present(renderingContext.drawable);
    
    commandBufferRef.commit();
}

void Renderer::setup() {
    Line::setup();
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
