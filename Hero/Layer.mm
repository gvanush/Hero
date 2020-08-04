//
//  Layer.mm
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

#import "Layer.h"

#include "Layer.hpp"

#include "apple/metal/Metal.h"

#include <memory>

@interface Layer () {
    std::unique_ptr<hero::Layer> _cpp;
}

@end

@implementation Layer

-(void) setPosition: (simd_float3) position {
    _cpp->setPosition(position);
}

-(simd_float3) position {
    return _cpp->position();
}

-(void) setSize: (simd_float2) size {
    _cpp->setSize(size);
}

-(simd_float2) size {
    return _cpp->size();
}

-(void) setColor: (simd_float4) color {
    _cpp->setColor(color);
}

-(simd_float4) color {
    return _cpp->color();
}

-(void) setTexture: (id<MTLTexture>) texture {
    _cpp->setTexture(apple::metal::TextureRef {texture});
}

-(id<MTLTexture>) texture {
    return _cpp->texture().obj<id<MTLTexture>>();
}

-(instancetype) init {
    if(self = [super init]) {
        _cpp = std::make_unique<hero::Layer>();
    }
    return self;
}

-(CppHandle) cppHandle {
    return _cpp.get();
}

@end
