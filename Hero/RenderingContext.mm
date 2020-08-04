//
//  RenderingContext.mm
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#import "RenderingContext.h"

#include "RenderingContext.hpp"

#include <memory>

@interface RenderingContext () {
    std::unique_ptr<hero::RenderingContext> _cpp;
}

@end

@implementation RenderingContext

-(void) setDrawable: (id<MTLDrawable>) drawable {
    _cpp->setDrawable(apple::metal::DrawableRef {drawable});
}

-(id<MTLDrawable>) drawable {
    return _cpp->drawable().obj<id>();
}

-(void) setDrawableSize: (simd_float2) drawableSize {
    _cpp->setDrawableSize(drawableSize);
}

-(simd_float2) drawableSize {
    return _cpp->drawableSize();
}

-(void) setRenderPassDescriptor: (MTLRenderPassDescriptor*) renderPassDescriptor {
    _cpp->setRenderpassDescriptor(apple::metal::RenderPassDescriptorRef {renderPassDescriptor});
}

-(MTLRenderPassDescriptor*) renderPassDescriptor {
    return _cpp->renderpassDescriptor().obj<id>();
}

-(instancetype) init {
    if(self = [super init]) {
        _cpp = std::make_unique<hero::RenderingContext>();
    }
    return self;
}

+(id<MTLDevice>) device {
    return hero::RenderingContext::device.obj<id>();
}

+(MTLPixelFormat) colorPixelFormat {
    return to<MTLPixelFormat>(hero::RenderingContext::kColorPixelFormat);
}

-(CppHandle) cppHandle {
    return _cpp.get();
}

@end
