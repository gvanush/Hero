//
//  Camera.mm
//  Hero
//
//  Created by Vanush Grigoryan on 9/30/20.
//

#import "Camera.h"

#include "Camera.hpp"

@implementation Camera

-(instancetype) initWithNear: (float) near far: (float) far aspectRatio: (float) aspectRatio {
    if (self = [super initWithCppHandle: new hero::Camera {near, far, aspectRatio}]) {
    }
    return self;
}

-(instancetype) init {
    return [self initWithNear: 0.0001 far: 1000.f aspectRatio: 1.f];
}

-(simd_float4) convertToWorld: (simd_float4) vec fromViewportWithSize: (Size2) viewportSize {
    return self.cpp->convertViewportToWorld(vec, viewportSize);
}

-(void) dealloc {
    delete self.cpp;
}

-(void) setAspectRatio: (float) aspectRatio {
    self.cpp->setAspectRatio(aspectRatio);
}

-(float) aspectRatio {
    return self.cpp->aspectRatio();
}

-(void) setFovy: (float) fovy {
    self.cpp->setFovy(fovy);
}

-(float) fovy {
    return self.cpp->fovy();
}

-(void) setOrthographicScale: (float) orthographicScale {
    self.cpp->setOrthographicScale(orthographicScale);
}

-(float) orthographicScale {
    return self.cpp->orthographicScale();
}

-(void) setNear: (float) near {
    self.cpp->setNear(near);
}

-(float) near {
    return self.cpp->near();
}

-(void) setFar: (float) far {
    self.cpp->setFar(far);
}

-(float) far {
    return self.cpp->far();
}

-(void) setProjection: (Projection) projection {
    self.cpp->setProjection(projection);
}

-(Projection) projection {
    return self.cpp->projection();
}

-(void) lookAt: (simd_float3) point up: (simd_float3) up {
    self.cpp->lookAt(point, up);
}

@end

@implementation Camera (Cpp)

-(hero::Camera*) cpp {
    return static_cast<hero::Camera*>(self.cppHandle);
}

@end
