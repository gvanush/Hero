//
//  Layer.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "SceneObject.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface Layer: SceneObject

-(instancetype) init;

@property (nonatomic, readwrite) simd_float2 size;
@property (nonatomic, readwrite) simd_float4 color;
@property (nonatomic, readwrite) id<MTLTexture> texture;

@end

#ifdef __cplusplus

namespace hero { class Layer; }

@interface Layer (Cpp)

-(hero::Layer*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
