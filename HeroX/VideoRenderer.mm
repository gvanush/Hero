//
//  VideoRenderer.mm
//  HeroX
//
//  Created by Vanush Grigoryan on 2/4/21.
//

#import "VideoRenderer.h"
#import "VideoPlayer.h"
#import "RenderingContext.h"
#import "TextureUtils.h"
#import "CoreGraphics+Extensions.h"

#include "VideoRenderer.hpp"
#include "Transform.hpp"
#include "ShaderTypes.h"
#include "GeometryUtils.hpp"

namespace hero {

namespace {

id<MTLRenderPipelineState> __pipelineState;
id<MTLBuffer> __vertexBuffer;

}

void VideoRenderer::render(void* renderingContext) {
    
    VideoPlayer* videoPlayer = getObjC(_videoPlayerProxy);
    
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    
    Uniforms uniforms;
    uniforms.projectionViewMatrix = context.projectionViewMatrix;
    uniforms.projectionViewModelMatrix = _transform->worldMatrix() * uniforms.projectionViewMatrix;
    
    [context.renderCommandEncoder setVertexBuffer: __vertexBuffer offset: 0 atIndex: kVertexInputIndexVertices];
    
    [context.renderCommandEncoder setVertexBytes: &uniforms length: sizeof(Uniforms) atIndex: kVertexInputIndexUniforms];
    
    const auto videoSize = toFloat2(videoPlayer.videoSize);
    [context.renderCommandEncoder setVertexBytes: &videoSize length: sizeof(videoSize) atIndex: kVertexInputIndexTextureSize];
    
    const auto videoRotation = simd::inverse(toFloat2x2(videoPlayer.preferredVideoTransform));
    const auto videoPreferredTransform = simd_matrix(simd_make_float3(videoRotation.columns[0], videoPlayer.preferredVideoTransform.tx), simd_make_float3(videoRotation.columns[1], videoPlayer.preferredVideoTransform.ty));
    [context.renderCommandEncoder setVertexBytes: &videoPreferredTransform length: sizeof(videoPreferredTransform) atIndex: kVertexInputIndexTexturePreferredTransform];
    
    [context.renderCommandEncoder setVertexBytes: &_size length: sizeof(_size) atIndex: kVertexInputIndexSize];
    
    [context.renderCommandEncoder setFragmentTexture: (videoPlayer.lumaTexture ? videoPlayer.lumaTexture : getWhiteUnitTexture()) atIndex: kFragmentInputIndexLumaTexture];
    [context.renderCommandEncoder setFragmentTexture: (videoPlayer.chromaTexture ? videoPlayer.chromaTexture : getWhiteUnitTexture()) atIndex: kFragmentInputIndexChromaTexture];
    
    [context.renderCommandEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: kTextureVertexCount];
    
}

bool VideoRenderer::raycast(const Ray& ray, float& normDistance) {
    constexpr auto kTolerance = 0.0001f;
    
    const auto localRay = hero::transform(ray, simd::inverse(_transform->worldMatrix()));
    const auto plane = makePlane(kZero, kBackward);
    
    if(!intersect(localRay, plane, kTolerance, normDistance)) {
        return false;;
    }
    
    const auto intersectionPoint = simd_make_float2(getRayPoint(localRay, normDistance));

    const AABR aabr {-0.5f * _size, 0.5f * _size};
    return contains(intersectionPoint, aabr);
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
    pipelineDescriptor.vertexFunction = [[RenderingContext defaultLibrary] newFunctionWithName: @"videoTextureVS"];
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

-(void)setVideoPlayer:(VideoPlayer *)videoPlayer {
    self.cpp->setVideoPlayerProxy(hero::makeObjCProxy(videoPlayer));
}

-(VideoPlayer *)videoPlayer {
    return getObjC(self.cpp->videoPlayerProxy());
}

@end

@implementation VideoRenderer (Cpp)

-(hero::VideoRenderer*) cpp {
    return static_cast<hero::VideoRenderer*>(self.cppHandle);
}

@end
