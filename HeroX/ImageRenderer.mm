//
//  Layer.mm
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "ImageRenderer.h"
#import "TextureUtils.h"
#import "RenderingContext.h"

#include "ImageRenderer.hpp"
#include "Transform.hpp"
#include "ShaderTypes.h"
#include "GeometryUtils.hpp"

#include <array>

namespace hero {

namespace {

id<MTLRenderPipelineState> __pipelineState;

id<MTLBuffer> getVertexBuffer(TextureOrientation orientation) {
    static __weak id<MTLBuffer> vertexBuffers[kTextureOrientationCount];
    
    if (auto buffer = vertexBuffers[orientation]; buffer) {
        return buffer;
    }
    // TODO: change storage mode to private using blit command encoder
    const auto vertices = getTextureVertices(orientation);
    id<MTLBuffer> buffer = [[RenderingContext device] newBufferWithBytes: vertices.data() length: vertices.size() * sizeof(TextureVertex) options: MTLResourceStorageModeShared | MTLHazardTrackingModeDefault | MTLCPUCacheModeDefaultCache];
    vertexBuffers[orientation] = buffer;
    
    return  buffer;
}

}

ImageRenderer::ImageRenderer(SceneObject& sceneObject, Layer layer)
: Renderer {sceneObject, layer}
, _size {1.f, 1.f}
, _color {1.f, 1.f, 1.f, 1.f}
, _textureProxy {TextureProxy {hero::getWhiteUnitTexture()}} {
}

void ImageRenderer::setup() {
    
    MTLRenderPipelineDescriptor* pipelineDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineDescriptor.label = @"ImageRenderer pipeline";
    pipelineDescriptor.vertexFunction = [[RenderingContext defaultLibrary] newFunctionWithName: @"layerVertexShader"];
    pipelineDescriptor.fragmentFunction = [[RenderingContext defaultLibrary] newFunctionWithName: @"layerFragmentShader"];
    pipelineDescriptor.colorAttachments[0].pixelFormat = [RenderingContext colorPixelFormat];
    pipelineDescriptor.depthAttachmentPixelFormat = [RenderingContext depthPixelFormat];
    
    NSError* error = nil;
    __pipelineState = [[RenderingContext device] newRenderPipelineStateWithDescriptor: pipelineDescriptor error: &error];
    assert(!error);
    
}

void ImageRenderer::preRender(void* renderingContext) {
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    [context.renderCommandEncoder setRenderPipelineState: __pipelineState];
}

void ImageRenderer::render(void* renderingContext) {
    
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    
    Uniforms uniforms;
    uniforms.projectionViewMatrix = context.projectionViewMatrix;
    uniforms.projectionViewModelMatrix = _transform->worldMatrix() * uniforms.projectionViewMatrix;
    
    [context.renderCommandEncoder setVertexBuffer: getVertexBuffer(_textureOritentation) offset: 0 atIndex: kVertexInputIndexVertices];
    
    [context.renderCommandEncoder setVertexBytes: &uniforms length: sizeof(Uniforms) atIndex: kVertexInputIndexUniforms];
    
    [context.renderCommandEncoder setVertexBytes: &_size length: sizeof(_size) atIndex: kVertexInputIndexSize];
    
    [context.renderCommandEncoder setFragmentBytes: &_color length: sizeof(_color) atIndex: kFragmentInputIndexColor];
    
    [context.renderCommandEncoder setFragmentTexture: _textureProxy.texture() atIndex: kFragmentInputIndexTexture];
    
    [context.renderCommandEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: kTextureVertexCount];
    
}

bool ImageRenderer::raycast(const Ray& ray, float& normDistance) {
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

void ImageRenderer::onStart() {
    _transform = get<Transform>();
}

void ImageRenderer::onComponentWillRemove([[maybe_unused]] ComponentTypeInfo typeInfo, Component*) {
    assert(!typeInfo.is<Transform>());
}

void ImageRenderer::setTextureProxy(TextureProxy textureProxy) {
    _textureProxy = (textureProxy ? textureProxy : TextureProxy {hero::getWhiteUnitTexture()});
}

simd::int2 ImageRenderer::textureSize() const {
    return getTextureSize(static_cast<int>(_textureProxy.texture().width), static_cast<int>(_textureProxy.texture().height), _textureOritentation);
}

}

// MARK: ObjC API
@implementation ImageRenderer

-(void) setSize: (simd_float2) size {
    self.cpp->setSize(size);
}

-(simd_float2) size {
    return self.cpp->size();
}

-(void) setColor: (simd_float4) color {
    self.cpp->setColor(color);
}

-(simd_float4) color {
    return self.cpp->color();
}

-(void) setTexture: (id<MTLTexture>) texture {
    self.cpp->setTextureProxy(hero::TextureProxy{texture});
}

-(id<MTLTexture>) texture {
    return self.cpp->textureProxy().texture();
}

-(void)setTextureOrientation:(TextureOrientation)textureOrientation {
    self.cpp->setTextureOrientation(textureOrientation);
}

-(TextureOrientation)textureOrientation {
    return self.cpp->textureOrientation();
}

-(simd_int2) textureSize {
    return self.cpp->textureSize();
}

@end

@implementation ImageRenderer (Cpp)

-(hero::ImageRenderer*) cpp {
    return static_cast<hero::ImageRenderer*>(self.cppHandle);
}

@end
