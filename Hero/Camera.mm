//
//  Camera.mm
//  Hero
//
//  Created by Vanush Grigoryan on 9/30/20.
//

#import "Camera.h"

#include "Camera.hpp"

@implementation Camera

-(instancetype) initWithOwnedCpp:(hero::ObjCWrappee *)cpp deleter:(CppHandleDeleter)deleter {
    if(self = [super initWithOwnedCpp: cpp deleter: deleter]) {
        if (auto number = hero::Camera::nextCameraNumber(); number > 0) {
            self.name = [NSString stringWithFormat: @"Camera %d", number];
        } else {
            self.name = @"Camera";
        }
    }
    return self;
}

-(instancetype) initWithNear: (float) near far: (float) far aspectRatio: (float) aspectRatio {
    return [self initWithOwnedCpp: new hero::Camera {near, far, aspectRatio} deleter:^(CppHandle handle) {
        delete static_cast<hero::Camera*>(handle);
    }];
}

-(simd_float3) convertWorldToViewport: (simd_float3) point viewportSize: (simd_float2) viewportSize {
    return self.cpp->convertWorldToViewport(point, viewportSize);
}

-(simd_float3) convertViewportToWorld: (simd_float3) point viewportSize: (simd_float2) viewportSize {
    return self.cpp->convertViewportToWorld(point, viewportSize);
}

-(simd_float3) convertWorldToNDC: (simd_float3) point {
    return self.cpp->convertWorldToNDC(point);
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
