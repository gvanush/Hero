//
//  MeshRenderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "MeshRenderer.hpp"

#import "SPTRenderingContext.h"
#import "ShaderTypes.h"

#import <Metal/Metal.h>

static id<MTLRenderPipelineState> __pipelineState;

static const AAPLVertex triangleVertices[] =
{
    // 2D positions,    RGBA colors
    { {  10,  -10, 0.0 }, { 1, 0, 0, 1 } },
    { { -10,  -10, 0.0 }, { 0, 1, 0, 1 } },
    { {    0,  10, 0.0 }, { 0, 0, 1, 1 } },
};

namespace spt {

void MeshRenderer::render(void* renderingContext) {
    
    SPTRenderingContext* rc = (__bridge SPTRenderingContext*) renderingContext;

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
    
    id<MTLFunction> vertexFunction = [[SPTRenderingContext defaultLibrary] newFunctionWithName:@"vertexShader"];
    id<MTLFunction> fragmentFunction = [[SPTRenderingContext defaultLibrary] newFunctionWithName:@"fragmentShader"];

    // Configure a pipeline descriptor that is used to create a pipeline state.
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"Simple Pipeline";
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = [SPTRenderingContext colorPixelFormat];

    NSError *error;
    __pipelineState = [[SPTRenderingContext device] newRenderPipelineStateWithDescriptor:pipelineStateDescriptor
                                                             error:&error];
            
    // Pipeline State creation could fail if the pipeline descriptor isn't set up properly.
    //  If the Metal API validation is enabled, you can find out more information about what
    //  went wrong.  (Metal API validation is enabled by default when a debug build is run
    //  from Xcode.)
    assert(__pipelineState);
    
}

}
