//
//  Layer.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "Component.h"
#import "TextureUtilsCommon.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface TextureRenderer: Component

@property (nonatomic, readwrite) simd_float2 size;
@property (nonatomic, readwrite) simd_float4 color;
@property (nonatomic, readwrite) id<MTLTexture> texture;
@property (nonatomic, readwrite) TextureOrientation textureOrientation;
@property (nonatomic, readonly) simd_int2 textureSize;

@end

#ifdef __cplusplus

namespace hero { class TextureRenderer; }

@interface TextureRenderer (Cpp)

-(hero::TextureRenderer*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
