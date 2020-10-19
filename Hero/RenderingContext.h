//
//  RenderingContext.h
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#import "CppWrapper.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>

#include <simd/simd.h>

NS_ASSUME_NONNULL_BEGIN

@interface RenderingContext : CppWrapper

@property (nonatomic, strong) id<MTLDrawable> drawable;
@property (nonatomic) simd_float2 viewportSize;
@property (nonatomic, strong) MTLRenderPassDescriptor* renderPassDescriptor;

+(id<MTLDevice>) device;
+(MTLPixelFormat) colorPixelFormat;

@end

#ifdef __cplusplus

namespace hero { class RenderingContext; }

@interface RenderingContext (Cpp)

-(hero::RenderingContext*) cpp;

@end

#endif

NS_ASSUME_NONNULL_END
