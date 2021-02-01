//
//  ImageRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#pragma once

#include "Renderer.hpp"
#include "GeometryUtils_Common.h"
#include "TextureUtilsCommon.h"
#include "TextureProxy.h"

#include <simd/simd.h>

namespace hero {

class SceneObject;
class Transform;

class ImageRenderer: public Renderer {
public:
    
    ImageRenderer(SceneObject& sceneObject, Layer layer = kLayerContent);
    
    inline void setSize(const simd::float2& size);
    inline const simd::float2& size() const;
    
    inline void setColor(const simd::float4& color);
    inline const simd::float4& color() const;
    
    void setTextureProxy(TextureProxy textureProxy);
    inline TextureProxy textureProxy() const;
    
    inline void setTextureOrientation(TextureOrientation imageOrientation);
    inline TextureOrientation textureOrientation() const;
    
    simd::int2 textureSize() const;
    
    void render(void* renderingContext);
    
    bool raycast(const Ray& ray, float& normDistance);
    
    void onStart() override;
    void onComponentWillRemove(ComponentTypeInfo typeInfo, Component*) override;
    
    static void setup();
    static void preRender(void* renderingContext);
    
    static constexpr auto category = ComponentCategory::renderer;
    
private:
    simd::float4 _color;
    simd::float2 _size;
    TextureProxy _textureProxy;
    Transform* _transform = nullptr;
    TextureOrientation _textureOritentation = kTextureOrientationUp;
};

void ImageRenderer::setSize(const simd::float2& size) {
    _size = size;
}

const simd::float2& ImageRenderer::size() const {
    return _size;
}

void ImageRenderer::setColor(const simd::float4& color) {
    _color = color;
}

const simd::float4& ImageRenderer::color() const {
    return _color;
}

TextureProxy ImageRenderer::textureProxy() const {
    return _textureProxy;
}

void ImageRenderer::setTextureOrientation(TextureOrientation textureOrientation) {
    _textureOritentation = textureOrientation;
}

TextureOrientation ImageRenderer::textureOrientation() const {
    return _textureOritentation;
}

}
