//
//  Renderer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 14.11.21.
//

#include "Renderer.hpp"
#include "MeshLook.h"
#include "PolylineLook.h"
#include "ArcLook.h"
#include "PointLook.h"
#include "OutlineLook.h"
#include "ResourceManager.hpp"
#include "Transformation.hpp"
#include "LineLookDepthBias.h"
#include "RenderableMaterials.h"
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
id<MTLRenderPipelineState> __arcPipelineState;
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

void renderPlainColorMesh(id<MTLRenderCommandEncoder> renderEncoder, const Registry& registry, SPTEntity entity, SPTMeshId meshId, const spt::PlainColorRenderableMaterial& material) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    
    [renderEncoder setFragmentBytes: &material.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    [renderEncoder setVertexBytes: &worldMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    const auto& mesh = ResourceManager::active().getMesh(meshId);
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderPhongMesh(id<MTLRenderCommandEncoder> renderEncoder, const Registry& registry, SPTEntity entity, SPTMeshId meshId, const spt::PhongRenderableMaterial& material) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    
    // TODO: Optimize this computation to not happen each frame (perhaps as part of instancing optimization)
    const auto& transposedInverseWorldMatrix = (simd_transpose(simd_inverse(worldMatrix)));
    [renderEncoder setVertexBytes: &transposedInverseWorldMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexTransposedInverseWorldMatrix];
    [renderEncoder setFragmentBytes: &material length: sizeof(spt::PhongRenderableMaterial) atIndex: kFragmentInputIndexMaterial];
    
    [renderEncoder setVertexBytes: &worldMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    const auto& mesh = ResourceManager::active().getMesh(meshId);
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderMeshDepthOnly(id<MTLRenderCommandEncoder> renderEncoder, const Registry& registry, SPTEntity entity, SPTMeshId meshId) {
    
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

void renderPolyline(id<MTLRenderCommandEncoder> renderEncoder, const Registry& registry, SPTEntity entity, const SPTPolylineLook& polylineLook) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    [renderEncoder setVertexBytes: &worldMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    const auto& polyline = ResourceManager::active().getPolyline(polylineLook.polylineId);
    
    [renderEncoder setVertexBytes: &polylineLook.thickness length: sizeof(float) atIndex: kVertexInputIndexThickness];
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) polyline.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [renderEncoder setFragmentBytes: &polylineLook.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) polyline.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: polyline.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderArc(id<MTLRenderCommandEncoder> renderEncoder, const Registry& registry, SPTEntity entity, const SPTArcLook& arcLook) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    [renderEncoder setVertexBytes: &worldMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    constexpr unsigned int totalPointCount = 120;
    const float deltaAngle = 2.f * M_PI / totalPointCount * (arcLook.endAngle >= arcLook.startAngle ? 1.f : -1.f);
    const unsigned int pointCount = std::min(static_cast<unsigned int>(ceil((arcLook.endAngle - arcLook.startAngle) / deltaAngle)), totalPointCount) + 1;
    
    ArcUniforms arcUniforms {arcLook.radius, arcLook.startAngle, arcLook.endAngle + deltaAngle, arcLook.thickness, pointCount};
    [renderEncoder setVertexBytes: &arcUniforms length: sizeof(ArcUniforms) atIndex: kVertexInputIndexArcUniforms];
    
    [renderEncoder setFragmentBytes: &arcLook.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    [renderEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: 2 * pointCount];
    
}

void renderPoint(id<MTLRenderCommandEncoder> renderEncoder, const Registry& registry, SPTEntity entity, const SPTPointLook& pointLook) {
    
    const auto& worldMatrix = registry.get<Transformation>(entity).global;
    
    const auto& worldPos = worldMatrix.columns[3].xyz;
    std::array<PointVertex, 4> vertices {
        PointVertex {worldPos, simd_float2 {-1.f, -1.f}},
        PointVertex {worldPos, simd_float2 {1.f, -1.f}},
        PointVertex {worldPos, simd_float2 {-1.f, 1.f}},
        PointVertex {worldPos, simd_float2 {1.f, 1.f}}
    };
    
    [renderEncoder setVertexBytes: vertices.data() length: sizeof(PointVertex) * vertices.size() atIndex: kVertexInputIndexVertices];
    [renderEncoder setVertexBytes: &pointLook.size length: sizeof(pointLook.size) atIndex: kVertexInputIndexSize];
    
    [renderEncoder setFragmentBytes: &pointLook.color length: sizeof(pointLook.color) atIndex: kFragmentInputIndexColor];
    
    [renderEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: vertices.size()];
    
}

void renderMeshOutline(id<MTLRenderCommandEncoder> renderEncoder, const Mesh& mesh, const SPTOutlineLook& outlineLook, const simd_float4x4& globalMatrix) {
    
    [renderEncoder setVertexBytes: &globalMatrix
                           length: sizeof(simd_float4x4)
                          atIndex: kVertexInputIndexWorldMatrix];
    
    [renderEncoder setVertexBytes: &outlineLook.thickness length: sizeof(float) atIndex: kVertexInputIndexThickness];
    
    id<MTLBuffer> vertexBuffer = (__bridge id<MTLBuffer>) mesh.vertexBuffer()->apiObject();
    [renderEncoder setVertexBuffer: vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [renderEncoder setFragmentBytes: &outlineLook.color length: sizeof(simd_float4) atIndex: kFragmentInputIndexColor];
    
    id<MTLBuffer> indexBuffer = (__bridge id<MTLBuffer>) mesh.indexBuffer()->apiObject();
    
    [renderEncoder drawIndexedPrimitives: MTLPrimitiveTypeTriangle indexCount: mesh.indexCount() indexType: MTLIndexTypeUInt16 indexBuffer: indexBuffer indexBufferOffset: 0];
    
}

void renderOutline(id<MTLRenderCommandEncoder> renderEncoder, const Registry& registry, SPTEntity entity, const SPTOutlineLook& outlineLook) {
    
    if(const auto meshLook = registry.try_get<SPTMeshLook>(entity)) {
        const auto& mesh = ResourceManager::active().getMesh(meshLook->meshId);
        renderMeshOutline(renderEncoder, mesh, outlineLook, registry.get<Transformation>(entity).global);
    }
    
}

void Renderer::render(const Registry& registry, void* renderingContext) {
    
    SPTRenderingContext* rc = (__bridge SPTRenderingContext*) renderingContext;

    _uniforms.viewportSize = rc.viewportSize;
    _uniforms.cameraPosition = rc.cameraPosition;
    _uniforms.projectionViewMatrix = rc.projectionViewMatrix;
    _uniforms.screenScale = rc.screenScale;
    
    // Create a render command encoder.
    id<MTLRenderCommandEncoder> renderEncoder = [rc.commandBuffer renderCommandEncoderWithDescriptor: rc.renderPassDescriptor];
    renderEncoder.label = @"Renderer encoder";
    [renderEncoder setViewport: MTLViewport {0.0, 0.0, rc.viewportSize.x, rc.viewportSize.y, 0.0, 1.0}];
    [renderEncoder setDepthStencilState: SPTRenderingContext.defaultDepthStencilState];
    [renderEncoder setCullMode: MTLCullModeBack];
    [renderEncoder setFrontFacingWinding: MTLWindingCounterClockwise];
    [renderEncoder setVertexBytes: &_uniforms length: sizeof(_uniforms) atIndex: kVertexInputIndexUniforms];
    [renderEncoder setFragmentBytes: &_uniforms length: sizeof(_uniforms) atIndex: kFragmentInputIndexUniforms];
    
    // Render meshes
    [renderEncoder setRenderPipelineState: __plainColorMeshPipelineState];
    const auto plainColorMeshLookView = registry.view<spt::PlainColorRenderableMaterial, SPTMeshLook>();
    plainColorMeshLookView.each([&registry, renderEncoder, rc] (auto entity, const auto& material, const auto& meshLook) {
        if(rc.lookCategories & meshLook.categories) {
            renderPlainColorMesh(renderEncoder, registry, entity, meshLook.meshId, material);
        }
    });
    
    [renderEncoder setRenderPipelineState: __blinnPhongMeshPipelineState];
    const auto phongMeshLookView = registry.view<spt::PhongRenderableMaterial, SPTMeshLook>();
    phongMeshLookView.each([&registry, renderEncoder, rc] (auto entity, const auto& material, const auto& meshLook) {
        if(rc.lookCategories & meshLook.categories) {
            renderPhongMesh(renderEncoder, registry, entity, meshLook.meshId, material);
        }
    });
    
    
    // Render outlines
//    [renderEncoder setRenderPipelineState: __outlinePipelineState];
//    [renderEncoder setCullMode: MTLCullModeFront];
//    [renderEncoder setDepthBias: 10.0f slopeScale: 10.f clamp: 0.f];
//
//    const auto outlineLookView = registry.view<SPTOutlineLook>();
//    outlineLookView.each([&registry, renderEncoder, rc] (auto entity, auto& outlineLook) {
//        if(rc.lookCategories & outlineLook.categories) {
//            renderOutline(renderEncoder, registry, entity, outlineLook);
//        }
//    });
    
//    [renderEncoder setCullMode: MTLCullModeBack];
    
    // Render polylines
    [renderEncoder setRenderPipelineState: __polylinePipelineState];
    const auto polylineLookView = registry.view<SPTPolylineLook>(entt::exclude<SPTLineLookDepthBias>);
    polylineLookView.each([&registry, renderEncoder, rc] (auto entity, auto& polylineLook) {
        if(rc.lookCategories & polylineLook.categories) {
            renderPolyline(renderEncoder, registry, entity, polylineLook);
        }
    });
    
    const auto depthBiasedPolylineLookView = registry.view<SPTPolylineLook, SPTLineLookDepthBias>();
    depthBiasedPolylineLookView.each([&registry, renderEncoder, rc] (auto entity, auto& polylineLook, auto& depthBias) {
        [renderEncoder setDepthBias: -depthBias.bias slopeScale: -depthBias.slopeScale clamp: depthBias.clamp];
        if(rc.lookCategories & polylineLook.categories) {
            renderPolyline(renderEncoder, registry, entity, polylineLook);
        }
    });
    
    // Render arcs
    [renderEncoder setRenderPipelineState: __arcPipelineState];
    const auto arcLookView = registry.view<SPTArcLook>(entt::exclude<SPTLineLookDepthBias>);
    arcLookView.each([&registry, renderEncoder, rc] (auto entity, auto& arcLook) {
        if(rc.lookCategories & arcLook.categories) {
            renderArc(renderEncoder, registry, entity, arcLook);
        }
    });
    
    const auto depthBiasedArcLookView = registry.view<SPTArcLook, SPTLineLookDepthBias>();
    depthBiasedArcLookView.each([&registry, renderEncoder, rc] (auto entity, auto& arcLook, auto& depthBias) {
        [renderEncoder setDepthBias: -depthBias.bias slopeScale: -depthBias.slopeScale clamp: depthBias.clamp];
        if(rc.lookCategories & arcLook.categories) {
            renderArc(renderEncoder, registry, entity, arcLook);
        }
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
    const auto pointLookView = registry.view<SPTPointLook>();
    pointLookView.each([&registry, layer1RenderEncoder, rc] (auto entity, auto& pointLook) {
        if(rc.lookCategories & pointLook.categories) {
            renderPoint(layer1RenderEncoder, registry, entity, pointLook);
        }
    });
    
    const auto outlineView = registry.view<SPTOutlineLook, SPTMeshLook>();
    // Render meshes in depth buffer
    [layer1RenderEncoder setRenderPipelineState: __depthOnlyMeshPipelineState];
    outlineView.each([layer1RenderEncoder, &registry, rc] (auto entity, auto&, auto& meshLook) {
        if(rc.lookCategories & meshLook.categories) {
            renderMeshDepthOnly(layer1RenderEncoder, registry, entity, meshLook.meshId);
        }
    });

    // Render outlines
    [layer1RenderEncoder setRenderPipelineState: __outlinePipelineState];
    [layer1RenderEncoder setCullMode: MTLCullModeFront];
    [layer1RenderEncoder setDepthBias: 100.0f slopeScale: 10.f clamp: 0.f];

    outlineView.each([layer1RenderEncoder, &registry, rc] (auto entity, auto& outlineLook, auto&) {
        if(rc.lookCategories & outlineLook.categories) {
            renderOutline(layer1RenderEncoder, registry, entity, outlineLook);
        }
    });
    
    [layer1RenderEncoder endEncoding];
    
}

void Renderer::init() {
    __plainColorMeshPipelineState = createPipelineState(@"Plain color mesh render pipeline", @"basicVS", @"basicFS");
    __blinnPhongMeshPipelineState = createPipelineState(@"Blinn-Phong mesh render pipeline", @"meshVS", @"blinnPhongFS");
    __depthOnlyMeshPipelineState = createDepthOnlyPipelineState(@"Depth only mesh render pipe;ime", @"basicVS");
    __polylinePipelineState = createPipelineState(@"Polyline render pipeline", @"polylineVS", @"basicFS");
    __arcPipelineState = createPipelineState(@"Arc render pipeline", @"arcVS", @"basicFS");
    __pointPipelineState = createPipelineState(@"Point render pipeline", @"pointVS", @"pointFS");
    __outlinePipelineState = createPipelineState(@"Outline render pipeline", @"outlineVS", @"basicFS");
}

}
