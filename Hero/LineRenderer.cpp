//
//  Line.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#include "LineRenderer.hpp"
#include "Transform.hpp"
#include "RenderingContext.hpp"

#include <vector>
#include <array>
#include <algorithm>

namespace hero {

namespace {

apple::metal::RenderPipelineStateRef __pipelineStateRef;

}

LineRenderer::LineRenderer(const SceneObject& sceneObject, const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color)
: Component {sceneObject}
, _color {color}
, _point1 {point1}
, _point2 {point2}
, _thickness {thickness} {
    
}

void LineRenderer::setup() {
    using namespace apple;
    
    const auto& device = RenderingContext::device;
    
    const auto& library = RenderingContext::library;
    
    const auto vertexFunctionRef = library.newFunction(u8"lineVS"_str);
    assert(vertexFunctionRef);
    const auto fragmentFunctionRef = library.newFunction(u8"uniformColorFS"_str);
    assert(fragmentFunctionRef);
    
    const auto pipelineStateDescriptorRef = metal::RenderPipelineDescriptor::create();
    pipelineStateDescriptorRef.setLabel(u8"Line rendering pipeline"_str);
    pipelineStateDescriptorRef.setVertexFunction(vertexFunctionRef);
    pipelineStateDescriptorRef.setFragmentFunction(fragmentFunctionRef);
    pipelineStateDescriptorRef.colorAttachments().objectAtIndex(0).setPixelFormat(RenderingContext::kColorPixelFormat);
    pipelineStateDescriptorRef.setDepthAttachmentPixelFormat(RenderingContext::kDepthPixelFormat);
//    pipelineStateDescriptorRef.setSampleCount(2);
    
    ErrorRef errorRef;
    __pipelineStateRef = device.newRenderPipelineState(pipelineStateDescriptorRef, &errorRef);
    assert(!errorRef);
}

void LineRenderer::render(RenderingContext& renderingContext) {
    
    // TODO: Move points to buffer
    using namespace apple;
    using namespace apple::metal;
    
    renderingContext.renderCommandEncoder.setRenderPipelineState(__pipelineStateRef);
    
    renderingContext.uniforms.projectionViewModelMatrix = _transform->worldMatrix() * renderingContext.uniforms.projectionViewMatrix;
    renderingContext.renderCommandEncoder.setVertexBytes(&renderingContext.uniforms, sizeof(hero::Uniforms), kVertexInputIndexUniforms);
    
    std::array<simd::float3, 4> vertices {_point1, _point2, _point1, _point2};
    renderingContext.renderCommandEncoder.setVertexBytes(vertices.data(), sizeof(vertices), kVertexInputIndexVertices);
    
    renderingContext.renderCommandEncoder.setVertexBytes(&_thickness, sizeof(_thickness), kVertexInputIndexThickness);
    
    renderingContext.renderCommandEncoder.setFragmentBytes(&_color, sizeof(_color), kFragmentInputIndexColor);
    
    renderingContext.renderCommandEncoder.drawPrimitives(PrimitiveType::triangleStrip, 0, vertices.size());
    
}

void LineRenderer::onEnter() {
    _transform = get<Transform>();
}

void LineRenderer::onRemoveComponent([[maybe_unused]] TypeId typeId, Component*) {
    assert(typeIdOf<Transform> != typeId);
}

}
