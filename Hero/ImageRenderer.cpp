//
//  ImageRenderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#include "ImageRenderer.hpp"
#include "Transform.hpp"
#include "TextureUtils.hpp"
#include "RenderingContext.hpp"
#include "ShaderTypes.h"
#include "GeometryUtils.hpp"

#include <array>
#include <vector>
#include <algorithm>

namespace hero {

namespace {

constexpr auto kHalfSize = 0.5f;
constexpr std::array<LayerVertex, 4> kImageVertices = {{
    {{-kHalfSize, -kHalfSize}, {0.f, 1.f}},
    {{kHalfSize, -kHalfSize}, {1.f, 1.f}},
    {{-kHalfSize, kHalfSize}, {0.f, 0.f}},
    {{kHalfSize, kHalfSize}, {1.f, 0.f}},
}};

apple::metal::RenderPipelineStateRef __pipelineStateRef;
apple::metal::BufferRef __vertexBuffer;

}

ImageRenderer::ImageRenderer(const SceneObject& sceneObject)
: Component(sceneObject)
, _size {1.f, 1.f}
, _color {1.f, 1.f, 1.f, 1.f}
, _texture {whiteUnitTexture()} {
}

void ImageRenderer::setTexture(const apple::metal::TextureRef& texture) {
    if(texture) {
        _texture = texture;
    } else {
        _texture = whiteUnitTexture();
    }
}

void ImageRenderer::setup() {
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
    __vertexBuffer = device.newBufferWithBytes(kImageVertices.data(), kImageVertices.size() * sizeof(LayerVertex), metal::ResourceOptions::storageModeShared | metal::ResourceOptions::hazardTrackingModeDefault | metal::ResourceOptions::cpuCacheModeDefaultCache);
}

void ImageRenderer::render(RenderingContext& renderingContext) {
    
    using namespace apple;
    using namespace apple::metal;
    
    renderingContext.renderCommandEncoder.setRenderPipelineState(__pipelineStateRef);
    
    renderingContext.renderCommandEncoder.setVertexBuffer(__vertexBuffer, 0, kVertexInputIndexVertices);
        
    renderingContext.uniforms.projectionViewModelMatrix = _transform->worldMatrix() * renderingContext.uniforms.projectionViewMatrix;
    renderingContext.renderCommandEncoder.setVertexBytes(&renderingContext.uniforms, sizeof(hero::Uniforms), kVertexInputIndexUniforms);
    
    renderingContext.renderCommandEncoder.setVertexBytes(&_size, sizeof(_size), kVertexInputIndexSize);
    
    renderingContext.renderCommandEncoder.setFragmentBytes(&_color, sizeof(_color), kFragmentInputIndexColor);
    renderingContext.renderCommandEncoder.setFragmentTexture(_texture, kFragmentInputIndexTexture);
    
    renderingContext.renderCommandEncoder.drawPrimitives(PrimitiveType::triangleStrip, 0, kImageVertices.size());
    
}

void ImageRenderer::onEnter() {
    _transform = get<Transform>();
}

void ImageRenderer::onRemoveComponent([[maybe_unused]] TypeId typeId, Component*) {
    assert(typeIdOf<Transform> != typeId);
}

/*ImageRenderer* ImageRenderer::raycast(const Ray& ray) {
    constexpr auto kTolerance = 0.0001f;
    
    ImageRenderer* result = nullptr;
    float minNormDistance = std::numeric_limits<float>::max();
    
    for(auto layer: __layers) {
        const auto localRay = hero::transform(ray, simd::inverse(layer->get<Transform>()->worldMatrix()));
        const auto plane = makePlane(kZero, kBackward);
        
        float normDistance;
        if(!intersect(localRay, plane, kTolerance, normDistance)) {
            continue;
        }
        
        const auto intersectionPoint = simd_make_float2(getRayPoint(localRay, normDistance));
    
        const AABR aabr {-0.5f * layer->size(), 0.5f * layer->size()};
        if(!contains(intersectionPoint, aabr)) {
            continue;
        }
        
        if(minNormDistance > normDistance) {
            result = layer;
            minNormDistance = normDistance;
        }
        
    }
    return result;
}*/

}
