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

#import <Metal/Metal.h>
#include <array>

namespace hero {

namespace {

id<MTLRenderPipelineState> __pipelineState;

}

LineRenderer::LineRenderer(SceneObject& sceneObject, const std::vector<simd::float3>& points, float thickness, const simd::float4& color)
: Component {sceneObject}
, _color {color}
, _points {points}
, _thickness {thickness} {
    assert(_points.size() > 1);
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

void LineRenderer::render(void* renderingContext) {
    
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    
    [context.renderCommandEncoder setRenderPipelineState: __pipelineState];
    
    Uniforms uniforms;
    uniforms.projectionViewMatrix = context.projectionViewMatrix;
    uniforms.projectionViewModelMatrix = _transform->worldMatrix() * uniforms.projectionViewMatrix;
    uniforms.viewportSize = context.viewportSize;

    [context.renderCommandEncoder setVertexBytes: &uniforms length: sizeof(Uniforms) atIndex: kVertexInputIndexUniforms];
    
    id<MTLBuffer> pointsBuffer = (__bridge id<MTLBuffer>) _pointsBuffer;
    [context.renderCommandEncoder setVertexBuffer: pointsBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [context.renderCommandEncoder setVertexBytes: &_thickness length: sizeof(_thickness) atIndex: kVertexInputIndexThickness];
    
    [context.renderCommandEncoder setFragmentBytes: &_color length: sizeof(_color) atIndex: kFragmentInputIndexColor];
    
    [context.renderCommandEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: pointsBuffer.length / sizeof(simd::float3)];
    
}

void LineRenderer::onStart() {
    _transform = get<hero::Transform>();
    
    id<MTLBuffer> pointsBuffer = [[RenderingContext device] newBufferWithLength: 4 * (_points.size() - 1) * sizeof(simd::float3) options: MTLResourceStorageModeShared | MTLResourceCPUCacheModeWriteCombined | MTLHazardTrackingModeUntracked];
    auto data = static_cast<simd::float3*>(pointsBuffer.contents);
    
    for(std::size_t segInd = 0, i = 0; segInd < _points.size() - 1; ++segInd, i += 4) {
        data[i] = _points[segInd];
        data[i + 1] = _points[segInd + 1];
        data[i + 2] = _points[segInd];
        data[i + 3] = _points[segInd + 1];
    }
    _pointsBuffer = (void*) CFBridgingRetain(pointsBuffer);
}

void LineRenderer::onStop() {
    CFRelease(_pointsBuffer);
}

void LineRenderer::onComponentWillRemove([[maybe_unused]] ComponentTypeInfo typeInfo, Component*) {
    assert(ComponentTypeInfo::get<Transform>() != typeInfo);
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
