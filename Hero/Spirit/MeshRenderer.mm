//
//  MeshRenderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "MeshRenderer.hpp"

#import "RenderingContext.h"
#import "ShaderTypes.h"

#import <Metal/Metal.h>

static id<MTLRenderPipelineState> __pipelineState;

static const AAPLVertex triangleVertices[] =
{
    // 2D positions,    RGBA colors
    { {  50,  -50, 500.0 }, { 1, 0, 0, 1 } },
    { { -50,  -50, 500.0 }, { 0, 1, 0, 1 } },
    { {    0,  50, 500.0 }, { 0, 0, 1, 1 } },
};

namespace spt {

void MeshRenderer::render(void* renderingContext) {
    
    RenderingContext* rc = (__bridge RenderingContext*) renderingContext;

    // Create a render command encoder.
    id<MTLRenderCommandEncoder> renderEncoder = rc.renderCommandEncoder;
    
    _uniforms.viewportSize = rc.viewportSize;
    _uniforms.projectionViewMatrix = rc.projectionViewMatrix;
    
    [renderEncoder setRenderPipelineState: __pipelineState];

    // Pass in the parameter data.
    [renderEncoder setVertexBytes: &_uniforms
                           length:sizeof(_uniforms)
                          atIndex:kVertexInputIndexUniforms];

    [renderEncoder setVertexBytes:triangleVertices
                           length:sizeof(triangleVertices)
                          atIndex:AAPLVertexInputIndexVertices];
    // Draw the triangle.
    [renderEncoder drawPrimitives:MTLPrimitiveTypeTriangle
                      vertexStart:0
                      vertexCount:3];
    
}

void MeshRenderer::init() {
    
    id<MTLFunction> vertexFunction = [[RenderingContext defaultLibrary] newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [[RenderingContext defaultLibrary] newFunctionWithName:@"fragmentShader"];

    // Configure a pipeline descriptor that is used to create a pipeline state.
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"Simple Pipeline";
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = [RenderingContext colorPixelFormat];

    NSError *error;
    __pipelineState = [[RenderingContext device] newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                             error:&error];
            
    // Pipeline State creation could fail if the pipeline descriptor isn't set up properly.
    //  If the Metal API validation is enabled, you can find out more information about what
    //  went wrong.  (Metal API validation is enabled by default when a debug build is run
    //  from Xcode.)
    assert(__pipelineState);
    
}

}
