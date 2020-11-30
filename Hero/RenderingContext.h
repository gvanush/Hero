//
//  RenderingContext.h
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#import "CppOwner.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderingContext : CppOwner

@property (nonatomic) simd_float2 viewportSize;
@property (nonatomic, strong) MTLRenderPassDescriptor* renderPassDescriptor;

+(id<MTLDevice>) device;
+(MTLPixelFormat) colorPixelFormat;
+(MTLPixelFormat) depthPixelFormat;

@end

#ifdef __cplusplus

namespace hero { class RenderingContext; }

@interface RenderingContext (Cpp)

-(hero::RenderingContext*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
