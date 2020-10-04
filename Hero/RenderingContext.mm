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
    if(self = [super initWithCppHandle: new hero::RenderingContext {}]) {
    }
    return self;
}

-(void) dealloc {
    delete self.cpp;
}

-(void) setDrawable: (id<MTLDrawable>) drawable {
    self.cpp->setDrawable(apple::metal::DrawableRef {drawable});
}

-(id<MTLDrawable>) drawable {
    return self.cpp->drawable().obj<id>();
}

-(void) setDrawableSize: (simd_float2) drawableSize {
    self.cpp->setDrawableSize(drawableSize);
}

-(simd_float2) drawableSize {
    return self.cpp->drawableSize();
}

-(void) setRenderPassDescriptor: (MTLRenderPassDescriptor*) renderPassDescriptor {
    self.cpp->setRenderpassDescriptor(apple::metal::RenderPassDescriptorRef {renderPassDescriptor});
}

-(MTLRenderPassDescriptor*) renderPassDescriptor {
    return self.cpp->renderpassDescriptor().obj<id>();
}

+(id<MTLDevice>) device {
    return hero::RenderingContext::device.obj<id>();
}

+(MTLPixelFormat) colorPixelFormat {
    return to<MTLPixelFormat>(hero::RenderingContext::kColorPixelFormat);
}

@end

@implementation RenderingContext (Cpp)

-(hero::RenderingContext*) cpp {
    return static_cast<hero::RenderingContext*>(self.cppHandle);
}

@end
