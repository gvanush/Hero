//
//  VideoMaterialProxy.h
//  Hero
//
//  Created by Vanush Grigoryan on 2/4/21.
//

#pragma once

#include "ObjCProxy.hpp"

namespace hero {

class VideoMaterialProxy: public ObjCProxy {
public:
    using ObjCProxy::ObjCProxy;
};

}

#ifdef __OBJC__

#import "Material.h"

namespace hero {

inline hero::VideoMaterialProxy makeObjCProxy(id<VideoMaterial> videoSource) {
    return hero::VideoMaterialProxy {(__bridge CFTypeRef) videoSource};
}

inline id<VideoMaterial> getObjC(hero::VideoMaterialProxy proxy) {
    return (__bridge id<VideoMaterial>) proxy.handle();
}

}

#endif

