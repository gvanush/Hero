//
//  Layer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#pragma once

#include "SceneObject.hpp"
#include "GeometryUtils_Common.h"

#include "apple/metal/Metal.h"

#include <simd/simd.h>

namespace hero {

class RenderingContext;

class Layer: public SceneObject {
public:
    
    using PositionType = simd::float3;
    using SizeType = simd::float2;
    using ColorType = simd::float4;
    
    Layer();
    ~Layer();
    
    inline void setSize(const SizeType& size);
    inline const SizeType& size() const;
    
    inline void setColor(const ColorType& color);
    inline const ColorType& color() const;
    
    void setTexture(const apple::metal::TextureRef& texture);
    inline const apple::metal::TextureRef& texture() const;
    
    static void setup();
    static void render(RenderingContext& renderingContext);
    static Layer* raycast(const Ray& ray);
    
    inline static uint32_t nextLayerNumber() {
        static uint32_t number = 0;
        return number++;
    }
    
private:
    SizeType _size;
    ColorType _color;
    apple::metal::TextureRef _texture;
};

void Layer::setSize(const SizeType& size) {
    _size = size;
}

const Layer::SizeType& Layer::size() const {
    return _size;
}

void Layer::setColor(const ColorType& color) {
    _color = color;
}

const Layer::ColorType& Layer::color() const {
    return _color;
}

const apple::metal::TextureRef& Layer::texture() const {
    return _texture;
}

}
