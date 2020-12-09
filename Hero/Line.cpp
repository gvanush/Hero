//
//  Line.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#include "Line.hpp"
#include "RenderingContext.hpp"

#include "apple/metal/Metal.h"

#include <vector>
#include <array>
#include <algorithm>

namespace hero {

namespace {

std::vector<Line*> __lines;

}

Line::Line(const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color)
: _color {color}
, _point1 {point1}
, _point2 {point2}
, _thickness {thickness} {
    __lines.push_back(this);
}

Line::~Line() {
    __lines.erase(std::find(__lines.begin(), __lines.end(), this));
}

namespace {

apple::metal::RenderPipelineStateRef __pipelineStateRef;

}

void Line::setup() {
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

void Line::render(RenderingContext& renderingContext) {
    
    if (__lines.empty()) {
        return;
    }
    
    using namespace apple;
    using namespace apple::metal;
    
    renderingContext.renderCommandEncoder.setRenderPipelineState(__pipelineStateRef);
    
    for(auto line: __lines) {
        
        renderingContext.uniforms.projectionViewModelMatrix = line->transform()->worldMatrix() * renderingContext.uniforms.projectionViewMatrix;
        renderingContext.renderCommandEncoder.setVertexBytes(&renderingContext.uniforms, sizeof(hero::Uniforms), kVertexInputIndexUniforms);
        
        std::array<simd::float3, 4> vertices {line->_point1, line->_point2, line->_point1, line->_point2};
        renderingContext.renderCommandEncoder.setVertexBytes(vertices.data(), sizeof(vertices), kVertexInputIndexVertices);
        
        renderingContext.renderCommandEncoder.setVertexBytes(&line->_thickness, sizeof(float), kVertexInputIndexThickness);
        
        renderingContext.renderCommandEncoder.setFragmentBytes(&line->color(), sizeof(line->color()), kFragmentInputIndexColor);
        
        renderingContext.renderCommandEncoder.drawPrimitives(PrimitiveType::triangleStrip, 0, vertices.size());
    }
    
}

}
