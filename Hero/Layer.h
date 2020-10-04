//
//  Layer.h
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "CppWrapper.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface Layer: CppWrapper

@property (nonatomic, readwrite) simd_float3 position;
@property (nonatomic, readwrite) simd_float2 size;
@property (nonatomic, readwrite) simd_float4 color;
@property (nonatomic, readwrite) id<MTLTexture> texture;

@end

NS_ASSUME_NONNULL_END
