//
//  World.cpp
//  Canvas
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#include "Canvas.hpp"
#include "RenderingContext.hpp"
#include "ShaderTypes.h"
#include "Layer.hpp"

#include "apple/metal/Metal.h"

#include <array>

namespace hero {

namespace {

constexpr auto kHalfSize = 0.5f;
constexpr std::array<LayerVertex, 4> kLayerVertices = {{
    {{-kHalfSize, -kHalfSize}, {0.f, 1.f}},
    {{kHalfSize, -kHalfSize}, {1.f, 1.f}},
    {{-kHalfSize, kHalfSize}, {0.f, 0.f}},
    {{kHalfSize, kHalfSize}, {1.f, 0.f}},
}};

}

Canvas::Canvas() {
    using namespace apple;
    
    const auto& device = RenderingContext::device;
    
    const auto& library = RenderingContext::library;
    
    const auto vertexFunctionRef = library.newFunction(u8"layerVertexShader"_str);
    assert(vertexFunctionRef);
    const auto fragmentFunctionRef = library.newFunction(u8"layerFragmentShader"_str);
    assert(fragmentFunctionRef);
    
    const auto pipelineStateDescriptorRef = metal::RenderPipelineDescriptor::create();
    pipelineStateDescriptorRef.setLabel(u8"Layer rendering pipeline"_str);
    pipelineStateDescriptorRef.setVertexFunction(vertexFunctionRef);
    pipelineStateDescriptorRef.setFragmentFunction(fragmentFunctionRef);
    pipelineStateDescriptorRef.colorAttachments().objectAtIndex(0).setPixelFormat(RenderingContext::kColorPixelFormat);
    
    ErrorRef errorRef;
    _pipelineStateRef = device.newRenderPipelineState(pipelineStateDescriptorRef, &errorRef);
    assert(!errorRef);
    
    // TODO: change storage mode to private using blit command encoder
    _vertexBuffer = device.newBufferWithBytes(kLayerVertices.data(), kLayerVertices.size() * sizeof(LayerVertex), metal::ResourceOptions::storageModeShared | metal::ResourceOptions::hazardTrackingModeDefault | metal::ResourceOptions::cpuCacheModeDefaultCache);
}

void Canvas::addLayer(Layer* layer) {
    _layers.push_back(layer);
}

void Canvas::render(RenderingContext* renderingContext) {
    
    using namespace apple;
    using namespace apple::metal;

    auto commandBufferRef = RenderingContext::commandQueue.newCommandBuffer();
    assert(commandBufferRef);
    commandBufferRef.setLabel(String::createWithUTF8String(u8"LayerCommandBuffer"));
    
    auto commandEncoderRef = commandBufferRef.newRenderCommandEncoder(renderingContext->renderpassDescriptor());
    assert(commandEncoderRef);
    commandEncoderRef.setLabel(String::createWithUTF8String(u8"LayerDrawingRenderEncoder"));
    
    commandEncoderRef.setRenderPipelineState(_pipelineStateRef);
    
    commandEncoderRef.setVertexBuffer(_vertexBuffer, 0, kVertexInputIndexVertices);
    
    commandEncoderRef.setVertexBytes(&renderingContext->drawableSize(), sizeof(RenderingContext::DrawableSizeType), kVertexInputIndexViewportSize);
    
    for(auto layer: _layers) {
        
        commandEncoderRef.setVertexBytes(&layer->size(), sizeof(Layer::SizeType), kVertexInputIndexSize);
        commandEncoderRef.setVertexBytes(&layer->position(), sizeof(Layer::PositionType), kVertexInputIndexPosition);
        commandEncoderRef.setFragmentBytes(&layer->color(), sizeof(Layer::ColorType), kFragmentInputIndexColor);
        commandEncoderRef.setFragmentTexture(layer->texture(), kFragmentInputIndexTexture);
        
        commandEncoderRef.drawPrimitives(PrimitiveType::triangleStrip, 0, kLayerVertices.size());
    }
    
    commandEncoderRef.endEncoding();
    
    commandBufferRef.present(renderingContext->drawable());
    
    commandBufferRef.commit();
    
}

}
