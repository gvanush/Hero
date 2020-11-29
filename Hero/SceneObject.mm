//
//  SceneObject.m
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "SceneObject.h"

#include "SceneObject.hpp"

@implementation SceneObject

-(instancetype) init {
    if (self = [super initWithCpp: new hero::SceneObject {}]) {
    }
    return self;
}

-(void) dealloc {
    delete self.cpp;
    [self resetCpp];
}

-(void) setPosition: (simd_float3) position {
    self.cpp->setPosition(position);
}

-(simd_float3) position {
    return self.cpp->position();
}

-(void) setScale: (simd_float3) scale {
    self.cpp->setScale(scale);
}

-(simd_float3) scale {
    return self.cpp->scale();
}

-(void) setRotation: (simd_float3) rotation {
    self.cpp->setRotation(rotation);
}

-(simd_float3) rotation {
    return self.cpp->rotation();
}

-(void) setEulerOrder: (EulerOrder) eulerOrder {
    self.cpp->setEulerOrder(eulerOrder);
}

-(EulerOrder)eulerOrder {
    return self.cpp->eulerOrder();
}

-(simd_float4x4) worldMatrix {
    return self.cpp->worldMatrix();
}

-(void) setWorldMatrix: (simd_float4x4) worldMatrix {
    
}

@end

@implementation SceneObject (Cpp)

-(hero::SceneObject*) cpp {
    return static_cast<hero::SceneObject*>(self.cppHandle);
}

@end
