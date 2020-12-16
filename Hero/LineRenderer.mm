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

LineRenderer::LineRenderer(SceneObject& sceneObject, const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color)
: Component {sceneObject}
, _color {color}
, _point1 {point1}
, _point2 {point2}
, _thickness {thickness} {
    
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
    
    // TODO: Move points to buffer
    
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    
    [context.renderCommandEncoder setRenderPipelineState: __pipelineState];
    
    Uniforms uniforms;
    uniforms.projectionViewMatrix = context.projectionViewMatrix;
    uniforms.projectionViewModelMatrix = _transform->worldMatrix() * uniforms.projectionViewMatrix;
    uniforms.viewportSize = context.viewportSize;

    [context.renderCommandEncoder setVertexBytes: &uniforms length: sizeof(Uniforms) atIndex: kVertexInputIndexUniforms];
    
    std::array<simd::float3, 4> vertices {_point1, _point2, _point1, _point2};
    [context.renderCommandEncoder setVertexBytes: vertices.data() length: sizeof(vertices) atIndex: kVertexInputIndexVertices];
    
    [context.renderCommandEncoder setVertexBytes: &_thickness length: sizeof(_thickness) atIndex: kVertexInputIndexThickness];
    
    [context.renderCommandEncoder setFragmentBytes: &_color length: sizeof(_color) atIndex: kFragmentInputIndexColor];
    
    [context.renderCommandEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: vertices.size()];
    
}

void LineRenderer::onStart() {
    _transform = get<hero::Transform>();
}

void LineRenderer::onComponentWillRemove([[maybe_unused]] TypeId typeId, Component*) {
    assert(typeIdOf<Transform> != typeId);
}

}


// MARK: ObjC API
@implementation LineRenderer

-(simd_float3) point1 {
    return self.cpp->point1();
}

-(simd_float3) point2 {
    return self.cpp->point2();
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
