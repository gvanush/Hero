//
//  Line.mm
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#import "LineRenderer.h"

#include "LineRenderer.hpp"

@implementation LineRenderer

-(simd_float3) point1 {
    return self.cpp->point1();
}

-(simd_float3) point2 {
    return self.cpp->point2();
}

-(void) setThickness: (float) thickness {
    self.cpp->setThickness(thickness);
}

-(float) thickness {
    return self.cpp->thickness();
}

-(void) setColor: (simd_float4) color {
    self.cpp->setColor(color);
}

-(simd_float4) color {
    return self.cpp->color();
}

@end

@implementation LineRenderer (Cpp)

-(hero::LineRenderer*) cpp {
    return static_cast<hero::LineRenderer*>(self.cppHandle);
}

@end
