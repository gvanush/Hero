//
//  Line.mm
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#import "Line.h"

#include "Line.hpp"

@implementation Line

-(instancetype) initWithPoint1: (simd_float3) point1 point2: (simd_float3) point2 thickness: (float) thickness color: (simd_float4) color {
    if (self = [super initWithCppHandle: new hero::Line {point1, point2, thickness, color}]) {
    }
    return self;
}

-(instancetype) initWithPoint1: (simd_float3) point1 point2: (simd_float3) point2 {
    return [self initWithPoint1: point1 point2: point2 thickness: 1.f color: simd_make_float4(1.f, 1.f, 1.f, 1.f)];
}

-(void) dealloc {
    delete self.cpp;
}

-(void) setPoint1: (simd_float3) point1 {
    self.cpp->setPoint1(point1);
}

-(simd_float3) point1 {
    return self.cpp->point1();
}

-(void) setPoint2: (simd_float3) point2 {
    self.cpp->setPoint2(point2);
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

@implementation Line (Cpp)

-(hero::Line*) cpp {
    return static_cast<hero::Line*>(self.cppHandle);
}

@end
