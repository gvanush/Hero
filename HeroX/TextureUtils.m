//
//  TextureUtils.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 8/4/20.
//

#import "TextureUtils.h"
#import "RenderingContext.h"

@implementation TextureUtils

+(id<MTLTexture>) whiteUnitTexture {
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

@end
