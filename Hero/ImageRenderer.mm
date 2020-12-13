//
//  Layer.mm
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "ImageRenderer.h"

#include "ImageRenderer.hpp"

#include "apple/metal/Metal.h"

@implementation ImageRenderer

-(void) setSize: (simd_float2) size {
    self.cpp->setSize(size);
}

-(simd_float2) size {
    return self.cpp->size();
}

-(void) setColor: (simd_float4) color {
    self.cpp->setColor(color);
}

-(simd_float4) color {
    return self.cpp->color();
}

-(void) setTexture: (id<MTLTexture>) texture {
    self.cpp->setTexture(apple::metal::TextureRef {texture});
}

-(id<MTLTexture>) texture {
    return self.cpp->texture().obj<id<MTLTexture>>();
}

@end

@implementation ImageRenderer (Cpp)

-(hero::ImageRenderer*) cpp {
    return static_cast<hero::ImageRenderer*>(self.cppHandle);
}

@end
