//
//  TextureUtils.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 8/4/20.
//

#import "TextureUtils.h"
#import "RenderingContext.h"

namespace hero {

id<MTLTexture> getWhiteUnitTexture() {
    static id<MTLTexture> texture = nil;
    if (!texture) {
        MTLTextureDescriptor* descr = [[MTLTextureDescriptor alloc] init];
        texture = [[RenderingContext device] newTextureWithDescriptor: descr];
        // Assuming 'BGRA8Unorm' pixel format (default value in descriptor)
        uint8_t kColor[4] = {255, 255, 255, 255};
        [texture replaceRegion: MTLRegionMake2D(0, 0, 1, 1) mipmapLevel: 0 withBytes: kColor bytesPerRow: 4];
    }
    return texture;
}
    
std::array<TextureVertex, kTextureVertexCount> getTextureVertices(TextureOrientation orientation) {
    constexpr auto kHalfSize = 0.5f;
    switch (orientation) {
        case kTextureOrientationDown:
            return {{
                {{-kHalfSize, -kHalfSize}, {1.f, 0.f}},
                {{kHalfSize, -kHalfSize}, {0.f, 0.f}},
                {{-kHalfSize, kHalfSize}, {1.f, 1.f}},
                {{kHalfSize, kHalfSize}, {0.f, 1.f}},
            }};
        case kTextureOrientationLeft:
            return {{
                {{-kHalfSize, -kHalfSize}, {0.f, 0.f}},
                {{kHalfSize, -kHalfSize}, {0.f, 1.f}},
                {{-kHalfSize, kHalfSize}, {1.f, 0.f}},
                {{kHalfSize, kHalfSize}, {1.f, 1.f}},
            }};
        case kTextureOrientationRight:
            return {{
                {{-kHalfSize, -kHalfSize}, {1.f, 1.f}},
                {{kHalfSize, -kHalfSize}, {1.f, 0.f}},
                {{-kHalfSize, kHalfSize}, {0.f, 1.f}},
                {{kHalfSize, kHalfSize}, {0.f, 0.f}},
            }};
        case kTextureOrientationUpMirrored:
            return {{
                {{-kHalfSize, -kHalfSize}, {1.f, 1.f}},
                {{kHalfSize, -kHalfSize}, {0.f, 1.f}},
                {{-kHalfSize, kHalfSize}, {1.f, 0.f}},
                {{kHalfSize, kHalfSize}, {0.f, 0.f}},
            }};
        case kTextureOrientationDownMirrored:
            return {{
                {{-kHalfSize, -kHalfSize}, {0.f, 0.f}},
                {{kHalfSize, -kHalfSize}, {1.f, 0.f}},
                {{-kHalfSize, kHalfSize}, {0.f, 1.f}},
                {{kHalfSize, kHalfSize}, {1.f, 1.f}},
            }};
        case kTextureOrientationLeftMirrored:
            return {{
                {{-kHalfSize, -kHalfSize}, {1.f, 0.f}},
                {{kHalfSize, -kHalfSize}, {1.f, 1.f}},
                {{-kHalfSize, kHalfSize}, {0.f, 0.f}},
                {{kHalfSize, kHalfSize}, {0.f, 1.f}},
            }};
        case kTextureOrientationRightMirrored:
            return {{
                {{-kHalfSize, -kHalfSize}, {0.f, 1.f}},
                {{kHalfSize, -kHalfSize}, {0.f, 0.f}},
                {{-kHalfSize, kHalfSize}, {1.f, 1.f}},
                {{kHalfSize, kHalfSize}, {1.f, 0.f}},
            }};
        default:
            return {{
                {{-kHalfSize, -kHalfSize}, {0.f, 1.f}},
                {{kHalfSize, -kHalfSize}, {1.f, 1.f}},
                {{-kHalfSize, kHalfSize}, {0.f, 0.f}},
                {{kHalfSize, kHalfSize}, {1.f, 0.f}},
            }};
    }
}
    

    
}
