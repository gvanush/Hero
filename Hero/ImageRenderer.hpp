//
//  ImageRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#pragma once

#include "Component.hpp"
#include "GeometryUtils_Common.h"

#include <simd/simd.h>

namespace hero {

class SceneObject;
class Transform;

class ImageRenderer: public Component {
public:
    
    ImageRenderer(SceneObject& sceneObject);
    ~ImageRenderer();
    
    inline void setSize(const simd::float2& size);
    inline const simd::float2& size() const;
    
    inline void setColor(const simd::float4& color);
    inline const simd::float4& color() const;
    
    void setTexture(void* texture);
    inline void* texture() const;
    
    void render(void* renderingContext);
    
    bool raycast(const Ray& ray, float& normDistance);
    
    void onEnter() override;
    void onRemoveComponent(TypeId typeId, Component*) override;
    
    static void setup();
    
    static constexpr auto category = ComponentCategory::renderer;
    
private:
    simd::float4 _color;
    simd::float2 _size;
    // TODO: 
    void* _texture;
    Transform* _transform = nullptr;
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

void* ImageRenderer::texture() const {
    return _texture;
}

}
