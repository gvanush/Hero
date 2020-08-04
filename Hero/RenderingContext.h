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

@interface RenderingContext : NSObject <CppWrapper>

@property (nonatomic, strong) id<MTLDrawable> drawable;
@property (nonatomic) simd_float2 drawableSize;
@property (nonatomic, strong) MTLRenderPassDescriptor* renderPassDescriptor;

+(id<MTLDevice>) device;
+(MTLPixelFormat) colorPixelFormat;

@end

NS_ASSUME_NONNULL_END
