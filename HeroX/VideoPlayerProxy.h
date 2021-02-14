//
//  VideoPlayerProxy.h
//  Hero
//
//  Created by Vanush Grigoryan on 2/7/21.
//

#pragma once

#include "ObjCProxy.hpp"

namespace hero {

class VideoPlayerProxy: public ObjCProxy {
public:
    using ObjCProxy::ObjCProxy;
};

}

#ifdef __OBJC__

#import "VideoPlayer.h"

namespace hero {

inline hero::VideoPlayerProxy makeObjCProxy(VideoPlayer* videoPlayer) {
    return hero::VideoPlayerProxy {(__bridge CFTypeRef) videoPlayer};
}

inline VideoPlayer* getObjC(hero::VideoPlayerProxy proxy) {
    return (__bridge VideoPlayer*) proxy.handle();
}

}

#endif
