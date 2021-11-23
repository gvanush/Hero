//
//  MeshRenderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "MeshRenderer.hpp"
#include "MeshRenderable.h"
#include "ResourceManager.hpp"
#include "Transformation.hpp"

#import "SPTRenderingContext.h"
#import "ShaderTypes.h"

#import <Metal/Metal.h>

static id<MTLRenderPipelineState> __pipelineState;

namespace spt {

MTLPrimitiveType getMTLPrimitiveType(Mesh::Geometry geometry) {
    switch (geometry) {
        case Mesh::Geometry::triangle:
            return MTLPrimitiveTypeTriangle;
        case Mesh::Geometry::triangleStrip:
            return MTLPrimitiveTypeTriangleStrip;
    }
}

MeshRenderer::MeshRenderer(Registry& registry)
: _registry {registry} {
    
}

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

    _registry.view<SPTMeshRenderable>().each([this, renderEncoder] (auto entity, auto& meshRenderable) {
        
        const auto& mesh = ResourceManager::active().getMesh(meshRenderable.meshId);
        
        if(auto worldMatrix = spt::getTransformationMatrix(_registry, entity); worldMatrix) {
            [renderEncoder setVertexBytes: worldMatrix
                                   length:sizeof(simd_float4x4)
                                  atIndex:kVertexInputIndexWorldMatrix];
        } else {
            [renderEncoder setVertexBytes: &matrix_identity_float4x4
                                   length:sizeof(simd_float4x4)
                                  atIndex:kVertexInputIndexWorldMatrix];
        }
        
        
        id<MTLBuffer> mtlBuffer = (__bridge id<MTLBuffer>) mesh.buffer();
        [renderEncoder setVertexBuffer: mtlBuffer offset: 0 atIndex: AAPLVertexInputIndexVertices];
        
        [renderEncoder drawPrimitives: getMTLPrimitiveType(mesh.geometry()) vertexStart: 0 vertexCount: mesh.vertexCount()];
    });
    
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
