//
//  Renderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Renderer.hpp"
#include "MeshView.h"
#include "Generator.hpp"
#include "PolylineView.h"
#include "PointView.h"
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

id<MTLRenderPipelineState> __plainColorMeshPipelineState;
id<MTLRenderPipelineState> __blinnPhongMeshPipelineState;
id<MTLRenderPipelineState> __depthOnlyMeshPipelineState;
id<MTLRenderPipelineState> __polylinePipelineState;
id<MTLRenderPipelineState> __pointPipelineState;
id<MTLRenderPipelineState> __outlinePipelineState;

}

id<MTLRenderPipelineState> createDepthOnlyPipelineState(NSString* name, NSString* vertexShaderName) {
    
    id<MTLFunction> vertexFunction = [[SPTRenderingContext defaultLibrary] newFunctionWithName: vertexShaderName];
    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = name;
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = nil;
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

void renderMesh(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, SPTEntity entity, const SPTMeshView& meshView) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    
    switch (meshView.shading) {
        case SPTMeshShadingPlainColor: {
            [renderEncoder setRenderPipelineState: __plainColorMeshPipelineState];
            [renderEncoder setFragmentBytes: &meshView.plainColor.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
            break;
        }
        case SPTMeshShadingBlinnPhong: {
            [renderEncoder setRenderPipelineState: __blinnPhongMeshPipelineState];
            // TODO: Optimize this computation to not happen each frame (perhaps as part of instancing optimization)
            const auto& transposedInverseWorldMatrix = (simd_transpose(simd_inverse(worldMatrix)));
            [renderEncoder setVertexBytes: &transposedInverseWorldMatrix
                                   length: sizeof(simd_float4x4)
                                  atIndex: kVertexInputIndexTransposedInverseWorldMatrix];
            [renderEncoder setFragmentBytes: &meshView.blinnPhong length: sizeof(PhongMaterial) atIndex: kFragmentInputIndexMaterial];
            break;
        }
    }
    
    [renderEncoder setVertexBytes: &worldMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    const auto& mesh = ResourceManager::active().getMesh(meshView.meshId);
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderMeshDepthOnly(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, SPTEntity entity, SPTMeshId meshId) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    
    [renderEncoder setVertexBytes: &worldMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    const auto& mesh = ResourceManager::active().getMesh(meshId);
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderPolyline(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, SPTEntity entity, const SPTPolylineView& polylineView) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    [renderEncoder setVertexBytes: &worldMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    const auto& polyline = ResourceManager::active().getPolyline(polylineView.polylineId);
    
    [renderEncoder setVertexBytes: &polylineView.thickness length: sizeof(float) atIndex: kVertexInputIndexThickness];
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) polyline.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [renderEncoder setFragmentBytes: &polylineView.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) polyline.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: polyline.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderPoint(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, SPTEntity entity, const SPTPointView& pointView) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    
    const auto& worldPos = worldMatrix.columns[3].xyz;
    std::array<PointVertex, 4> vertices {
        PointVertex {worldPos, simd_float2 {-1.f, -1.f}},
        PointVertex {worldPos, simd_float2 {1.f, -1.f}},
        PointVertex {worldPos, simd_float2 {-1.f, 1.f}},
        PointVertex {worldPos, simd_float2 {1.f, 1.f}}
    };
    
    [renderEncoder setVertexBytes: vertices.data() length: sizeof(PointVertex) * vertices.size() atIndex: kVertexInputIndexVertices];
    [renderEncoder setVertexBytes: &pointView.size length: sizeof(pointView.size) atIndex: kVertexInputIndexSize];
    
    [renderEncoder setFragmentBytes: &pointView.color length: sizeof(pointView.color) atIndex: kFragmentInputIndexColor];
    
    [renderEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: vertices.size()];
    
}

void renderMeshOutline(id<MTLRenderCommandEncoder> renderEncoder, const Mesh& mesh, const SPTOutlineView& outlineView, const simd_float4x4& globalMatrix) {
    
    [renderEncoder setVertexBytes: &globalMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    [renderEncoder setVertexBytes: &outlineView.thickness length: sizeof(float) atIndex: kVertexInputIndexThickness];
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [renderEncoder setFragmentBytes: &outlineView.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderOutline(id<MTLRenderCommandEncoder> renderEncoder, Registry& registry, SPTEntity entity, const SPTOutlineView& outlineView) {
    
    if(const auto meshView = registry.try_get<SPTMeshView>(entity)) {
        const auto& mesh = ResourceManager::active().getMesh(meshView->meshId);
        renderMeshOutline(renderEncoder, mesh, outlineView, registry.get<Transformation>(entity).global);
    }
    
    if(const auto generator = registry.try_get<spt::Generator>(entity)) {
        
        const auto& mesh = ResourceManager::active().getMesh(generator->base.sourceMeshId);
        
        // TODO: Refactor to access only generator items
        Transformation::forEachChild(registry, entity, [&registry, &renderEncoder, &mesh, &outlineView] (auto childEntity, const auto& childTran) {
            renderMeshOutline(renderEncoder, mesh, outlineView, childTran.global);
        });
    }
}

Renderer::Renderer(Registry& registry)
: _registry {registry} {
}

void Renderer::render(void* renderingContext) {
    
    SPTRenderingContext* rc = (__bridge SPTRenderingContext*) renderingContext;

    _uniforms.viewportSize = rc.viewportSize;
    _uniforms.cameraPosition = rc.cameraPosition;
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
    [renderEncoder setFragmentBytes: &_uniforms length: sizeof(_uniforms) atIndex: kFragmentInputIndexUniforms];
    
    // Render meshes
    const auto meshView = _registry.view<SPTMeshView>();
    meshView.each([this, renderEncoder] (auto entity, auto& meshView) {
        renderMesh(renderEncoder, _registry, entity, meshView);
    });
    
    // Render outlines
    [renderEncoder setRenderPipelineState: __outlinePipelineState];
    [renderEncoder setCullMode: MTLCullModeFront];
//    [renderEncoder setDepthBias: 100.0f slopeScale: 10.f clamp: 0.f];

    const auto outlineView = _registry.view<SPTOutlineView>();
    outlineView.each([this, renderEncoder] (auto entity, auto& outlineView) {
        renderOutline(renderEncoder, _registry, entity, outlineView);
    });
    
    // Render polylines
    [renderEncoder setCullMode: MTLCullModeBack];
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
    
    [renderEncoder endEncoding];
    
    // Render layer 1
    MTLRenderPassDescriptor* layer1Descriptor = [rc.renderPassDescriptor copy];
    layer1Descriptor.colorAttachments[0].loadAction = MTLLoadActionLoad;
    layer1Descriptor.depthAttachment.loadAction = MTLLoadActionClear;
    
    id<MTLRenderCommandEncoder> layer1RenderEncoder = [rc.commandBuffer renderCommandEncoderWithDescriptor: layer1Descriptor];
    layer1RenderEncoder.label = @"Layer1 renderer encoder";
    [layer1RenderEncoder setViewport: MTLViewport {0.0, 0.0, rc.viewportSize.x, rc.viewportSize.y, 0.0, 1.0 }];
    [layer1RenderEncoder setDepthStencilState: SPTRenderingContext.defaultDepthStencilState];
    [layer1RenderEncoder setCullMode: MTLCullModeBack];
    [layer1RenderEncoder setFrontFacingWinding: MTLWindingCounterClockwise];
    [layer1RenderEncoder setVertexBytes: &_uniforms length: sizeof(_uniforms) atIndex: kVertexInputIndexUniforms];
    [layer1RenderEncoder setFragmentBytes: &_uniforms length: sizeof(_uniforms) atIndex: kFragmentInputIndexUniforms];
    
    [layer1RenderEncoder setRenderPipelineState: __pointPipelineState];
    const auto pointView = _registry.view<SPTPointView>();
    pointView.each([this, layer1RenderEncoder] (auto entity, auto& pointView) {
        renderPoint(layer1RenderEncoder, _registry, entity, pointView);
    });
    
//    const auto outlineView = _registry.view<SPTOutlineView>();
//    if(!outlineView.empty()) {
//
//        // Render meshes in depth buffer
//        [layer1RenderEncoder setRenderPipelineState: __depthOnlyMeshPipelineState];
//        outlineView.each([this, layer1RenderEncoder] (auto entity, auto& outlineView) {
//            renderMeshDepthOnly(layer1RenderEncoder, _registry, entity, outlineView.meshId);
//        });
//
//        // Render outlines
//        [layer1RenderEncoder setRenderPipelineState: __outlinePipelineState];
//        [layer1RenderEncoder setCullMode: MTLCullModeFront];
//    //    [renderEncoder setDepthBias: 100.0f slopeScale: 10.f clamp: 0.f];
//
//        outlineView.each([this, layer1RenderEncoder] (auto entity, auto& outlineView) {
//            renderOutline(layer1RenderEncoder, _registry, entity, outlineView);
//        });
//    }
    
    [layer1RenderEncoder endEncoding];
    
}

void Renderer::init() {
    __plainColorMeshPipelineState = createPipelineState(@"Plain color mesh render pipeline", @"basicVS", @"basicFS");
    __blinnPhongMeshPipelineState = createPipelineState(@"Blinn-Phong mesh render pipeline", @"meshVS", @"blinnPhongFS");
    __depthOnlyMeshPipelineState = createDepthOnlyPipelineState(@"Depth only mesh render pipe;ime", @"basicVS");
    __polylinePipelineState = createPipelineState(@"Polyline render pipeline", @"polylineVS", @"basicFS");
    __pointPipelineState = createPipelineState(@"Polyline render pipeline", @"pointVS", @"pointFS");
    __outlinePipelineState = createPipelineState(@"Outline render pipeline", @"outlineVS", @"basicFS");
}

}