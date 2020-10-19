//
//  Layer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#include "Layer.hpp"
#include "TextureUtils.hpp"
#include "RenderingContext.hpp"
#include "ShaderTypes.h"

#include <array>
#include <vector>
#include <algorithm>

namespace hero {

namespace {

std::vector<Layer*> __layers;

}

Layer::Layer()
: _size {1.f, 1.f}
, _color {1.f, 1.f, 1.f, 1.f}
, _texture {whiteUnitTexture()} {
    __layers.push_back(this);
}

Layer::~Layer() {
    __layers.erase(std::find(__layers.begin(), __layers.end(), this));
}

void Layer::setTexture(const apple::metal::TextureRef& texture) {
    if(texture) {
        _texture = texture;
    } else {
        _texture = whiteUnitTexture();
    }
}

namespace {

constexpr auto kHalfSize = 0.5f;
constexpr std::array<LayerVertex, 4> kLayerVertices = {{
    {{-kHalfSize, -kHalfSize}, {0.f, 1.f}},
    {{kHalfSize, -kHalfSize}, {1.f, 1.f}},
    {{-kHalfSize, kHalfSize}, {0.f, 0.f}},
    {{kHalfSize, kHalfSize}, {1.f, 0.f}},
}};

apple::metal::RenderPipelineStateRef __pipelineStateRef;
apple::metal::BufferRef __vertexBuffer;

}

void Layer::setup() {
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
    pipelineStateDescriptorRef.setDepthAttachmentPixelFormat(RenderingContext::kDepthPixelFormat);
//    pipelineStateDescriptorRef.setSampleCount(2);
    
    ErrorRef errorRef;
    __pipelineStateRef = device.newRenderPipelineState(pipelineStateDescriptorRef, &errorRef);
    assert(!errorRef);
    
    // TODO: change storage mode to private using blit command encoder
    __vertexBuffer = device.newBufferWithBytes(kLayerVertices.data(), kLayerVertices.size() * sizeof(LayerVertex), metal::ResourceOptions::storageModeShared | metal::ResourceOptions::hazardTrackingModeDefault | metal::ResourceOptions::cpuCacheModeDefaultCache);
}

void Layer::render(RenderingContext& renderingContext) {
    
    if (__layers.empty()) {
        return;
    }
    
    using namespace apple;
    using namespace apple::metal;
    
    renderingContext.renderCommandEncoder.setRenderPipelineState(__pipelineStateRef);
    
    renderingContext.renderCommandEncoder.setVertexBuffer(__vertexBuffer, 0, kVertexInputIndexVertices);
        
    for(auto layer: __layers) {
        
        renderingContext.uniforms.projectionViewModelMatrix = layer->worldMatrix() * renderingContext.uniforms.projectionViewMatrix;
        renderingContext.renderCommandEncoder.setVertexBytes(&renderingContext.uniforms, sizeof(hero::Uniforms), kVertexInputIndexUniforms);
        
        renderingContext.renderCommandEncoder.setVertexBytes(&layer->size(), sizeof(Layer::SizeType), kVertexInputIndexSize);
        
        renderingContext.renderCommandEncoder.setFragmentBytes(&layer->color(), sizeof(Layer::ColorType), kFragmentInputIndexColor);
        renderingContext.renderCommandEncoder.setFragmentTexture(layer->texture(), kFragmentInputIndexTexture);
        
        renderingContext.renderCommandEncoder.drawPrimitives(PrimitiveType::triangleStrip, 0, kLayerVertices.size());
    }
    
}

}
