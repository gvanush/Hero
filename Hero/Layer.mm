//
//  Layer.mm
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "Layer.h"

#include "Layer.hpp"

#include "apple/metal/Metal.h"

@implementation Layer

-(instancetype) init {
    return [self initWithOwnedCpp: new hero::Layer {} deleter:^(CppHandle handle) {
        delete static_cast<hero::Layer*>(handle);
    }];
}

-(instancetype)initWithOwnedCpp: (CppHandle) cpp deleter:(CppHandleDeleter)deleter {
    if (self = [super initWithOwnedCpp: cpp deleter: deleter]) {
        if (auto number = hero::Layer::nextLayerNumber(); number > 0) {
            self.name = [NSString stringWithFormat: @"Layer %d", number];
        } else {
            self.name = @"Layer";
        }
    }
    return self;
}

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

@implementation Layer (Cpp)

-(hero::Layer*) cpp {
    return static_cast<hero::Layer*>(self.cppHandle);
}

@end
