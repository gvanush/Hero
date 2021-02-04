//
//  TextureProxy.h
//  Hero
//
//  Created by Vanush Grigoryan on 1/31/21.
//

#pragma once

#include "ObjCProxy.hpp"

namespace hero {

class TextureProxy: public ObjCProxy {
public:
    using ObjCProxy::ObjCProxy;
};

#ifdef __OBJC__

#import <Metal/Metal.h>

inline hero::TextureProxy makeObjCProxy(id<MTLTexture> texture) {
    return hero::TextureProxy {(__bridge CFTypeRef) texture};
}

inline id<MTLTexture> getObjC(hero::TextureProxy proxy) {
    return (__bridge id<MTLTexture>) proxy.handle();
}

#endif

}
