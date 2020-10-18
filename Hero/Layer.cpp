//
//  Layer.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/30/20.
//

#include "Layer.hpp"
#include "TextureUtils.hpp"

namespace hero {

Layer::Layer()
: _size {1.f, 1.f}
, _color {1.f, 1.f, 1.f, 1.f}
, _texture {whiteUnitTexture()} {
    
}

void Layer::setTexture(const apple::metal::TextureRef& texture) {
    if(texture) {
        _texture = texture;
    } else {
        _texture = whiteUnitTexture();
    }
}

}
