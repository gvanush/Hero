//
//  Layer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#pragma once

#include "apple/metal/Metal.h"

#include <simd/simd.h>

namespace hero {

class Layer {
public:
    
    using PositionType = simd::float3;
    using SizeType = simd::float2;
    using ColorType = simd::float4;
    
    Layer();
    
    inline void setPosition(const PositionType& pos);
    inline const PositionType& position() const;
    
    inline void setSize(const SizeType& size);
    inline const SizeType& size() const;
    
    inline void setColor(const ColorType& color);
    inline const ColorType& color() const;
    
    void setTexture(const apple::metal::TextureRef& texture);
    inline const apple::metal::TextureRef& texture() const;
    
private:
    PositionType _position;
    SizeType _size;
    ColorType _color;
    apple::metal::TextureRef _texture;
};

void Layer::setPosition(const PositionType& pos) {
    _position = pos;
}

const Layer::PositionType& Layer::position() const {
    return _position;
}

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
