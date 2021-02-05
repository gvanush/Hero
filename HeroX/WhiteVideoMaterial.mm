//
//  WhiteVideoSource.m
//  HeroX
//
//  Created by Vanush Grigoryan on 2/4/21.
//

#import "WhiteVideoMaterial.h"
#import "TextureUtils.h"

@implementation WhiteVideoMaterial

- (nonnull id<MTLTexture>) chromaTexture {
    return hero::getWhiteUnitTexture();
}

- (nonnull id<MTLTexture>) lumaTexture {
    return hero::getWhiteUnitTexture();
}

- (void)update {
}

@end
