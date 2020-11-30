//
//  RenderingContext.mm
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#import "RenderingContext.h"

#include "RenderingContext.hpp"

@implementation RenderingContext

-(instancetype) init {
    if(self = [super initWithCpp: new hero::RenderingContext {}]) {
    }
    return self;
}

-(void) dealloc {
    delete self.cpp;
    [self resetCpp];
}

-(void) setViewportSize: (simd_float2) viewportSize {
    self.cpp->uniforms.viewportSize = viewportSize;
}

-(simd_float2) viewportSize {
    return self.cpp->uniforms.viewportSize;
}

-(void) setRenderPassDescriptor: (MTLRenderPassDescriptor*) renderPassDescriptor {
    self.cpp->renderPassDescriptor = apple::metal::RenderPassDescriptorRef {renderPassDescriptor};
}

-(MTLRenderPassDescriptor*) renderPassDescriptor {
    return self.cpp->renderPassDescriptor.obj<id>();
}

+(id<MTLDevice>) device {
    return hero::RenderingContext::device.obj<id>();
}

+(MTLPixelFormat) colorPixelFormat {
    return to<MTLPixelFormat>(hero::RenderingContext::kColorPixelFormat);
}

+(MTLPixelFormat) depthPixelFormat {
    return to<MTLPixelFormat>(hero::RenderingContext::kDepthPixelFormat);
}

@end

@implementation RenderingContext (Cpp)

-(hero::RenderingContext*) cpp {
    return static_cast<hero::RenderingContext*>(self.cppHandle);
}

@end
