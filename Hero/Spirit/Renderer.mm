//
//  Renderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Renderer.hpp"
#include "PlainColorMeshView.h"
#include "PolylineView.h"
#include "OutlineView.h"
#include "ResourceManager.hpp"
#include "Transformation.hpp"
#include "PolylineViewDepthBias.h"
#import "SPTRenderingContext.h"
#import "ShaderTypes.h"

#import <Metal/Metal.h>
#include <iostream>

namespace spt {

namespace {

id<MTLRenderPipelineState> __meshPipelineState;
id<MTLRenderPipelineState> __polylinePipelineState;
id<MTLRenderPipelineState> __outlinePipelineState;

}

id<MTLRenderPipelineState> createPipelineState(NSString* name, NSString* vertexShaderName, NSString* fragmentShaderName) {
    id<MTLFunction> vertexFunction = [[SPTRenderingContext defaultLibrary] newFunctionWithName: vertexShaderName];
    id<MTLFunction> fragmentFunction = [[SPTRenderingContext defaultLibrary] newFunctionWithName: fragmentShaderName];

    // Configure a pipeline descriptor that is used to create a pipeline state.
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = name;
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = [SPTRenderingContext colorPixelFormat];
    pipelineStateDescriptor.depthAttachmentPixelFormat = [SPTRenderingContext depthPixelFormat];
    
    NSError *error;
    id<MTLRenderPipelineState> pipelineState = [[SPTRenderingContext device] newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error: &error];
    if(!pipelineState) {
        std::cerr << [error localizedDescription] << std::endl;
        std::exit(1);
    }
    
    return pipelineState;
}

void setupWorldMatrix(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, const SPTEntity& entity) {
    if(auto worldMatrix = spt::getTransformationMatrix(registry, entity); worldMatrix) {
        [renderEncoder setVertexBytes: worldMatrix
                               length:sizeof(simd_float4x4)
                              atIndex:kVertexInputIndexWorldMatrix];
    } else {
        [renderEncoder setVertexBytes: &matrix_identity_float4x4
                               length:sizeof(simd_float4x4)
                              atIndex:kVertexInputIndexWorldMatrix];
    }
}

void renderMesh(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, const SPTEntity& entity, const SPTPlainColorMeshView& meshView) {
    
    setupWorldMatrix(renderEncoder, registry, entity);
    
    const auto& mesh = ResourceManager::active().getMesh(meshView.meshId);
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [renderEncoder setFragmentBytes: &meshView.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderPolyline(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, const SPTEntity& entity, const SPTPolylineView& polylineView) {
    
    setupWorldMatrix(renderEncoder, registry, entity);
    
    const auto& polyline = ResourceManager::active().getPolyline(polylineView.polylineId);
    
    [renderEncoder setVertexBytes: &polylineView.thickness length: sizeof(float) atIndex: kVertexInputIndexThickness];
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) polyline.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [renderEncoder setFragmentBytes: &polylineView.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) polyline.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: polyline.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderOutline(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, const SPTEntity& entity, const SPTOutlineView& outlineView) {
    
    setupWorldMatrix(renderEncoder, registry, entity);
    
    const auto& mesh = ResourceManager::active().getMesh(outlineView.meshId);
    
    [renderEncoder setVertexBytes: &outlineView.thickness length: sizeof(float) atIndex: kVertexInputIndexThickness];
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [renderEncoder setFragmentBytes: &outlineView.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

Renderer::Renderer(Registry& registry)
: _registry {registry} {
    
}

void Renderer::render(void* renderingContext) {
    
    SPTRenderingContext* rc = (__bridge SPTRenderingContext*) renderingContext;

    _uniforms.viewportSize = rc.viewportSize;
    _uniforms.projectionViewMatrix = rc.projectionViewMatrix;
    _uniforms.screenScale = rc.screenScale;
    
    // Create a render command encoder.
    id<MTLRenderCommandEncoder> renderEncoder = [rc.commandBuffer renderCommandEncoderWithDescriptor: rc.renderPassDescriptor];
    renderEncoder.label = @"Renderer encoder";
    [renderEncoder setViewport: MTLViewport {0.0, 0.0, rc.viewportSize.x, rc.viewportSize.y, 0.0, 1.0 }];
    [renderEncoder setDepthStencilState: SPTRenderingContext.defaultDepthStencilState];
    [renderEncoder setCullMode: MTLCullModeBack];
    [renderEncoder setFrontFacingWinding: MTLWindingCounterClockwise];
    [renderEncoder setVertexBytes: &_uniforms length: sizeof(_uniforms) atIndex: kVertexInputIndexUniforms];
    
    // Render meshes
    [renderEncoder setRenderPipelineState: __meshPipelineState];
    const auto meshView = _registry.view<SPTPlainColorMeshView>();
    meshView.each([this, renderEncoder] (auto entity, auto& meshView) {
        renderMesh(renderEncoder, _registry, entity, meshView);
    });
    
    // Render polylines
    [renderEncoder setRenderPipelineState: __polylinePipelineState];
    const auto polylineView = _registry.view<SPTPolylineView>(entt::exclude<SPTPolylineViewDepthBias>);
    polylineView.each([this, renderEncoder] (auto entity, auto& polylineView) {
        renderPolyline(renderEncoder, _registry, entity, polylineView);
    });
    
    const auto depthBiasedPolylineView = _registry.view<SPTPolylineView, SPTPolylineViewDepthBias>();
    depthBiasedPolylineView.each([this, renderEncoder] (auto entity, auto& polylineView, auto& depthBias) {
        [renderEncoder setDepthBias: -depthBias.bias slopeScale: -depthBias.slopeScale clamp: depthBias.clamp];
        renderPolyline(renderEncoder, _registry, entity, polylineView);
    });
    
    // Render outlines
    [renderEncoder setRenderPipelineState: __outlinePipelineState];
    [renderEncoder setCullMode: MTLCullModeFront];
    [renderEncoder setDepthBias: 100.0f slopeScale: 10.f clamp: 0.f];
    
    const auto outlineView = _registry.view<SPTOutlineView>();
    outlineView.each([this, renderEncoder] (auto entity, auto& outlineView) {
        renderOutline(renderEncoder, _registry, entity, outlineView);
    });
    
    [renderEncoder endEncoding];
}

void Renderer::init() {
    __meshPipelineState = createPipelineState(@"Mesh render pipeline", @"vertexShader", @"fragmentShader");
    __polylinePipelineState = createPipelineState(@"Polyline render pipeline", @"polylineVertexShader", @"fragmentShader");
    __outlinePipelineState = createPipelineState(@"Outline render pipeline", @"outlineVertexShader", @"fragmentShader");
}

}
