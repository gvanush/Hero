//
//  RenderingContext.mm
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#import "RenderingContext.h"

@implementation RenderingContext

static id<MTLDevice> __device;
static id<MTLCommandQueue> __defaultCommandQueue;
static id<MTLLibrary> __defaultLibrary;
static id<MTLDepthStencilState> __defaultDepthStencilState;
static const MTLPixelFormat kColorPixelFormat = MTLPixelFormatBGRA8Unorm;
static const MTLPixelFormat kDepthPixelFormat = MTLPixelFormatDepth32Float;

+(id<MTLDevice>) device {
    return __device;
}

+(id<MTLCommandQueue>)defaultCommandQueue {
    return __defaultCommandQueue;
}

+(id<MTLLibrary>) defaultLibrary {
    return __defaultLibrary;
}

+(id<MTLDepthStencilState>)defaultDepthStencilState {
    return __defaultDepthStencilState;
}

+(MTLPixelFormat) colorPixelFormat {
    return kColorPixelFormat;
}

+(MTLPixelFormat) depthPixelFormat {
    return kDepthPixelFormat;
}

+(void) setup {
    __device = MTLCreateSystemDefaultDevice();
    __defaultCommandQueue = [__device newCommandQueue];
    __defaultLibrary = [__device newDefaultLibrary];
    
    MTLDepthStencilDescriptor* descr = [[MTLDepthStencilDescriptor alloc] init];
    descr.depthWriteEnabled = YES;
    descr.depthCompareFunction = MTLCompareFunctionLess;
    __defaultDepthStencilState = [__device newDepthStencilStateWithDescriptor: descr];
}

@end
