//
//  Layer.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "Component.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface ImageRenderer: Component

@property (nonatomic, readwrite) simd_float2 size;
@property (nonatomic, readwrite) simd_float4 color;
@property (nonatomic, readwrite) id<MTLTexture> texture;

@end

#ifdef __cplusplus

namespace hero { class ImageRenderer; }

@interface ImageRenderer (Cpp)

-(hero::ImageRenderer*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
