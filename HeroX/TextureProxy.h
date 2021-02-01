//
//  TextureProxy.h
//  Hero
//
//  Created by Vanush Grigoryan on 1/31/21.
//

#pragma once

#include "ObjCProxy.hpp"

#ifdef __OBJC__

#import <Metal/Metal.h>

#endif

namespace hero {

class TextureProxy: public ObjCProxy {
public:
    
#ifdef __OBJC__

    TextureProxy(id<MTLTexture> texture)
    : ObjCProxy { texture } {
    }
    
    id<MTLTexture> texture() const {
        return (__bridge id<MTLTexture>) handle();
    }
    
#endif
    
};

}
