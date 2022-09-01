//
//  RenderingContext.h
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#include "Base.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <CoreVideo/CoreVideo.h>

#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface SPTRenderingContext: NSObject

@property (nonatomic) SPTLookCategories lookCategories;
@property (nonatomic) simd_float4x4 projectionViewMatrix;
@property (nonatomic) simd_float3 cameraPosition;
@property (nonatomic) simd_float2 viewportSize;
@property (nonatomic) float screenScale;
@property (nonatomic, strong) id<MTLCommandBuffer> commandBuffer;
@property (nonatomic, strong) MTLRenderPassDescriptor* _Nullable  renderPassDescriptor;

+(id<MTLDevice>) device;
+(id<MTLCommandQueue>) defaultCommandQueue;
+(id<MTLLibrary>) defaultLibrary;
+(id<MTLDepthStencilState>) defaultDepthStencilState;

+(MTLPixelFormat) colorPixelFormat;
+(MTLPixelFormat) depthPixelFormat;

+(void) setup;

@end

NS_ASSUME_NONNULL_END
