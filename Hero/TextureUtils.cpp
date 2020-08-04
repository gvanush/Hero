//
//  TextureUtils.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 8/4/20.
//

#include "TextureUtils.hpp"
#include "RenderingContext.hpp"

namespace hero {

apple::metal::TextureRef whiteUnitTexture() {
    using namespace apple::metal;
    
    static TextureRef texture;
    if(!texture) {
        const auto texDesc = TextureDescriptor::create();
        texture = RenderingContext::device.newTextureWithDescriptor(texDesc);
        // Assuming 'BGRA8Unorm' pixel format (default value in descriptor)
        constexpr uint8_t kColor[4] = {255, 255, 255, 255};
        texture.replaceRegion(Region::create2D(0, 0, 1, 1), 0, kColor, 4);
    }
    return texture;
}

}
