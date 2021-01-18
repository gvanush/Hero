//
//  Transform.mm
//  Hero
//
//  Created by Vanush Grigoryan on 12/9/20.
//

#import "Transform.h"

#include "Transform.hpp"

@implementation Transform

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

@end

@implementation Transform (Cpp)

-(hero::Transform*) cpp {
    return static_cast<hero::Transform*>(self.cppHandle);
}

@end
