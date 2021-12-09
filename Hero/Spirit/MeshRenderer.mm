//
//  MeshRenderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "MeshRenderer.hpp"
#include "MeshView.h"
#include "ResourceManager.hpp"
#include "Transformation.hpp"
#include "ViewDepthBias.h"
#import "SPTRenderingContext.h"
#import "ShaderTypes.h"

#import <Metal/Metal.h>

static id<MTLRenderPipelineState> __pipelineState;

namespace spt {

MeshRenderer::MeshRenderer(Registry& registry)
: _registry {registry} {
    
}

void MeshRenderer::render(void* renderingContext) {
    
    SPTRenderingContext* rc = (__bridge SPTRenderingContext*) renderingContext;

    // Create a render command encoder.
    id<MTLRenderCommandEncoder> renderEncoder = rc.renderCommandEncoder;
    
    _uniforms.viewportSize = rc.viewportSize;
    _uniforms.projectionViewMatrix = rc.projectionViewMatrix;
    _uniforms.screenScale = rc.screenScale;
    
    [renderEncoder setRenderPipelineState: __pipelineState];

    // Pass in the parameter data.
    [renderEncoder setVertexBytes: &_uniforms
                           length:sizeof(_uniforms)
                          atIndex:kVertexInputIndexUniforms];

    auto render = [this, renderEncoder] (auto entity, auto& meshView) {
        
        const auto& mesh = ResourceManager::active().getMesh(meshView.meshId);
        
        if(auto worldMatrix = spt::getTransformationMatrix(_registry, entity); worldMatrix) {
            [renderEncoder setVertexBytes: worldMatrix
                                   length:sizeof(simd_float4x4)
                                  atIndex:kVertexInputIndexWorldMatrix];
        } else {
            [renderEncoder setVertexBytes: &matrix_identity_float4x4
                                   length:sizeof(simd_float4x4)
                                  atIndex:kVertexInputIndexWorldMatrix];
        }
        
        id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
        [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
        
        [renderEncoder setFragmentBytes: &meshView.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
        
        id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
        
        [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    };
    
    const auto meshView = _registry.view<SPTMeshView>(entt::exclude<SPTViewDepthBias>);
    meshView.each(render);
    
    const auto depthBiasedMeshView = _registry.view<SPTMeshView, SPTViewDepthBias>();
    depthBiasedMeshView.each([this, renderEncoder, render] (auto entity, auto& polylineView, auto& depthBias) {
        [renderEncoder setDepthBias: -depthBias.bias slopeScale: -depthBias.slopeScale clamp: depthBias.clamp];
        render(entity, polylineView);
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
    pipelineStateDescriptor.depthAttachmentPixelFormat = [SPTRenderingContext depthPixelFormat];
    
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
