//
//  VideoRenderer.mm
//  HeroX
//
//  Created by Vanush Grigoryan on 2/4/21.
//

#import "VideoRenderer.h"
#import "Material.h"
#import "GreenVideoMaterial.h"
#import "RenderingContext.h"
#import "TextureUtils.h"

#include "VideoRenderer.hpp"
#include "Transform.hpp"
#include "ShaderTypes.h"

namespace hero {

namespace {

id<MTLRenderPipelineState> __pipelineState;
id<MTLBuffer> __vertexBuffer;

}

void VideoRenderer::setMaterialProxy(VideoMaterialProxy proxy) {
    _materialProxy = (proxy ? proxy : makeObjCProxy( [[GreenVideoMaterial alloc] init] ));
}

void VideoRenderer::render(void* renderingContext) {
    
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    
    Uniforms uniforms;
    uniforms.projectionViewMatrix = context.projectionViewMatrix;
    uniforms.projectionViewModelMatrix = _transform->worldMatrix() * uniforms.projectionViewMatrix;
    
    [context.renderCommandEncoder setVertexBuffer: __vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [context.renderCommandEncoder setVertexBytes: &uniforms length: sizeof(Uniforms) atIndex: kVertexInputIndexUniforms];
    
    [context.renderCommandEncoder setVertexBytes: &_size length: sizeof(_size) atIndex: kVertexInputIndexSize];
    
    id<VideoMaterial> material = getObjC(_materialProxy);
    [context.renderCommandEncoder setFragmentTexture: material.lumaTexture atIndex: kFragmentInputIndexLumaTexture];
    [context.renderCommandEncoder setFragmentTexture: material.chromaTexture atIndex: kFragmentInputIndexChromaTexture];
    
    [context.renderCommandEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: kTextureVertexCount];
    
}

void VideoRenderer::onStart() {
    _transform = get<Transform>();
}

void VideoRenderer::onComponentWillRemove([[maybe_unused]] ComponentTypeInfo typeInfo, Component*) {
    assert(!typeInfo.is<Transform>());
}

void VideoRenderer::setup() {
    
    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.label = @"VideoRenderer pipeline";
    pipelineDescriptor.vertexFunction = [[RenderingContext defaultLibrary] newFunctionWithName: @"textureVS"];
    pipelineDescriptor.fragmentFunction = [[RenderingContext defaultLibrary] newFunctionWithName: @"videoFS"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = [RenderingContext colorPixelFormat];
    pipelineDescriptor.depthAttachmentPixelFormat = [RenderingContext depthPixelFormat];
    
    NSError* error = nil;
    __pipelineState = [[RenderingContext device] newRenderPipelineStateWithDescriptor: pipelineDescriptor error: &error];
    assert(!error);
    
    const auto vertices = getTextureVertices(kTextureOrientationUp);
    __vertexBuffer = [[RenderingContext device] newBufferWithBytes: vertices.data() length: vertices.size() * sizeof(TextureVertex) options: MTLResourceStorageModeShared | MTLHazardTrackingModeDefault | MTLCPUCacheModeDefaultCache];
    
}

void VideoRenderer::preRender(void* renderingContext) {
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    [context.renderCommandEncoder setRenderPipelineState: __pipelineState];
}

}

// MARK: ObjC API
@implementation VideoRenderer

-(void) setSize: (simd_float2) size {
    self.cpp->setSize(size);
}

-(simd_float2) size {
    return self.cpp->size();
}

-(void) setMaterial: (id<VideoMaterial>) material {
    self.cpp->setMaterialProxy(hero::makeObjCProxy(material));
}

-(id<VideoMaterial>) material {
    return getObjC(self.cpp->materialProxy());
}

@end

@implementation VideoRenderer (Cpp)

-(hero::VideoRenderer*) cpp {
    return static_cast<hero::VideoRenderer*>(self.cppHandle);
}

@end
