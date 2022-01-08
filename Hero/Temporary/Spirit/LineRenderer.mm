//
//  Line.mm
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#import "LineRenderer.h"
#import "RenderingContext.h"
#import "ShaderTypes.h"
#include "Transform.hpp"
#include "LineRenderer.hpp"
#include "Math.hpp"

#import <Metal/Metal.h>
#include <array>

namespace hero {

namespace {

id<MTLRenderPipelineState> __pipelineState;

}

LineRenderer::LineRenderer(SceneObject& sceneObject, const std::vector<simd::float3>& points, bool closed, Layer layer)
: Renderer {sceneObject, layer}
, _points {points}
, _closed {closed} {
    assert(_closed ? _points.size() > 2 : _points.size() > 1);
    
    // TODO: change storage mode to private using blit command encoder
    const std::size_t kBufferPointCount = 2 * (_closed ? _points.size() + 3 : _points.size() + 2);
    id<MTLBuffer> pointsBuffer = [[RenderingContext device] newBufferWithLength: kBufferPointCount * sizeof(simd::float3) options: MTLResourceStorageModeShared | MTLResourceCPUCacheModeWriteCombined | MTLHazardTrackingModeUntracked];
    auto data = static_cast<simd::float3*>(pointsBuffer.contents);
    
    // Commonly for each point there are two matching points in the buffer.
    // But the edge points are additionally set at the beginning and end of the buffer to simplify the shader.
    if (_closed) {
        data[0] = _points[_points.size() - 1];
    } else {
        data[0] = 2.f * _points[0] - _points[1];
    }
    data[1] = data[0];
    
    constexpr std::size_t kOffset = 2;
    for(std::size_t pi = 0; pi < _points.size(); ++pi) {
        data[2 * pi + kOffset] = _points[pi];
        data[2 * pi + 1 + kOffset] = _points[pi];
    }
    
    if (_closed) {
        data[kBufferPointCount - 4] = _points[0];
        data[kBufferPointCount - 3] = _points[0];
        data[kBufferPointCount - 2] = _points[1];
        data[kBufferPointCount - 1] = _points[1];
    } else {
        data[kBufferPointCount - 2] = 2.f * _points[_points.size() - 1] - _points[_points.size() - 2];
        data[kBufferPointCount - 1] = data[kBufferPointCount - 2];
    }
    _pointsBuffer = (void*) CFBridgingRetain(pointsBuffer);
}

LineRenderer::~LineRenderer() {
    CFRelease(_pointsBuffer);
}

void LineRenderer::setup() {
    
    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.label = @"LineRenderer pipeline";
    pipelineDescriptor.vertexFunction = [[RenderingContext defaultLibrary] newFunctionWithName: @"lineVS"];
    pipelineDescriptor.fragmentFunction = [[RenderingContext defaultLibrary] newFunctionWithName: @"uniformColorFS"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = [RenderingContext colorPixelFormat];
    pipelineDescriptor.depthAttachmentPixelFormat = [RenderingContext depthPixelFormat];
    
    NSError* error = nil;
    __pipelineState = [[RenderingContext device] newRenderPipelineStateWithDescriptor: pipelineDescriptor error: &error];
    assert(!error);
    
}

void LineRenderer::preRender(void* renderingContext) {
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    [context.renderCommandEncoder setRenderPipelineState: __pipelineState];
}

void LineRenderer::render(void* renderingContext) {
    
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    
    Uniforms uniforms;
//    uniforms.projectionViewMatrix = context.projectionViewMatrix;
//    uniforms.projectionViewModelMatrix = _transform->worldMatrix() * uniforms.projectionViewMatrix;
    uniforms.viewportSize = context.viewportSize;

    [context.renderCommandEncoder setVertexBytes: &uniforms length: sizeof(Uniforms) atIndex: kVertexInputIndexUniforms];
    
    id<MTLBuffer> pointsBuffer = (__bridge id<MTLBuffer>) _pointsBuffer;
    [context.renderCommandEncoder setVertexBuffer: pointsBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [context.renderCommandEncoder setVertexBytes: &_thickness length: sizeof(_thickness) atIndex: kVertexInputIndexThickness];
    [context.renderCommandEncoder setVertexBytes: &_miterLimit length: sizeof(_miterLimit) atIndex: kVertexInputIndexMiterLimit];
    
    [context.renderCommandEncoder setFragmentBytes: &_color length: sizeof(_color) atIndex: kFragmentInputIndexColor];
    
    [context.renderCommandEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 2 vertexCount: 2 * _points.size() + (_closed ? 2 : 0)];
    
}

void LineRenderer::onStart() {
    _transform = get<hero::Transform>();
}

void LineRenderer::onComponentWillRemove([[maybe_unused]] ComponentTypeInfo typeInfo, Component*) {
    assert(!typeInfo.is<Transform>());
}

}


// MARK: ObjC API
@implementation LineRenderer

-(const simd_float3 *)points {
    return self.cpp->points().data();
}

-(NSUInteger)pointsCount {
    return self.cpp->points().size();
}

-(void) setThickness: (float) thickness {
    self.cpp->setThickness(thickness);
}

-(float) thickness {
    return self.cpp->thickness();
}

-(void) setColor: (simd_float4) color {
    self.cpp->setColor(color);
}

-(simd_float4) color {
    return self.cpp->color();
}

@end

@implementation LineRenderer (Cpp)

-(hero::LineRenderer*) cpp {
    return static_cast<hero::LineRenderer*>(self.cppHandle);
}

@end
