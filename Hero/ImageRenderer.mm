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

constexpr auto kHalfSize = 0.5f;
constexpr std::array<ImageVertex, 4> kImageVertices = {{
    {{-kHalfSize, -kHalfSize}, {0.f, 1.f}},
    {{kHalfSize, -kHalfSize}, {1.f, 1.f}},
    {{-kHalfSize, kHalfSize}, {0.f, 0.f}},
    {{kHalfSize, kHalfSize}, {1.f, 0.f}},
}};

id<MTLRenderPipelineState> __pipelineState;
id<MTLBuffer> __vertexBuffer;

}

ImageRenderer::ImageRenderer(SceneObject& sceneObject)
: Component(sceneObject)
, _size {1.f, 1.f}
, _color {1.f, 1.f, 1.f, 1.f}
, _texture {(__bridge_retained void*) [TextureUtils whiteUnitTexture]} {
}

ImageRenderer::~ImageRenderer() {
    if(_texture) {
        CFRelease(_texture);
    }
}

void ImageRenderer::setTexture(void* texture) {
    if(texture) {
        CFRetain(texture);
        if(_texture) {
            CFRelease(_texture);
        }
        _texture = texture;
    } else {
        if(_texture) {
            CFRelease(_texture);
        }
        _texture = (__bridge_retained void*) [TextureUtils whiteUnitTexture];
    }
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
    
    // TODO: change storage mode to private using blit command encoder
    __vertexBuffer = [[RenderingContext device] newBufferWithBytes: kImageVertices.data() length: kImageVertices.size() * sizeof(ImageVertex) options: MTLResourceStorageModeShared | MTLHazardTrackingModeDefault | MTLCPUCacheModeDefaultCache];
}

void ImageRenderer::render(void* renderingContext) {
    
    RenderingContext* context = (__bridge RenderingContext*) renderingContext;
    
    [context.renderCommandEncoder setRenderPipelineState: __pipelineState];
    
    [context.renderCommandEncoder setVertexBuffer:__vertexBuffer offset: 0  atIndex: kVertexInputIndexVertices];
        
    Uniforms uniforms;
    uniforms.projectionViewMatrix = context.projectionViewMatrix;
    uniforms.projectionViewModelMatrix = _transform->worldMatrix() * uniforms.projectionViewMatrix;
    
    [context.renderCommandEncoder setVertexBytes: &uniforms length: sizeof(Uniforms) atIndex: kVertexInputIndexUniforms];
    
    [context.renderCommandEncoder setVertexBytes: &_size length: sizeof(_size) atIndex: kVertexInputIndexSize];
    
    [context.renderCommandEncoder setFragmentBytes: &_color length: sizeof(_color) atIndex: kFragmentInputIndexColor];
    
    [context.renderCommandEncoder setFragmentTexture: (__bridge id<MTLTexture>) _texture atIndex: kFragmentInputIndexTexture];
    
    [context.renderCommandEncoder drawPrimitives: MTLPrimitiveTypeTriangleStrip vertexStart: 0 vertexCount: kImageVertices.size()];
    
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
    assert(ComponentTypeInfo::get<Transform>() != typeInfo);
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
    self.cpp->setTexture((__bridge void*) texture);
}

-(id<MTLTexture>) texture {
    return (__bridge id<MTLTexture>) self.cpp->texture();
}

@end

@implementation ImageRenderer (Cpp)

-(hero::ImageRenderer*) cpp {
    return static_cast<hero::ImageRenderer*>(self.cppHandle);
}

@end
