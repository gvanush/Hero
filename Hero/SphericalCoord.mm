//
//  SphericalCoord.mm
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#import "SphericalCoord.h"

#include "SphericalCoord.hpp"

@implementation SphericalCoord

-(instancetype) init {
    if (self = [super initWithCppHandle: new hero::SphericalCoord {}]) {
    }
    return self;
}

-(void) dealloc {
    delete self.cpp;
}

-(simd_float3) getPosition {
    return self.cpp->getPosition();
}

-(void) setCenter: (simd_float3) center {
    self.cpp->center = center;
}

-(simd_float3) center {
    return self.cpp->center;
}

-(void) setRadius: (float) radius {
    self.cpp->radius = radius;
}

-(float) radius {
    return self.cpp->radius;
}

-(void) setLongitude: (float) longitude {
    self.cpp->longitude = longitude;
}

-(float) longitude {
    return self.cpp->longitude;
}

-(void) setLatitude: (float) latitude {
    self.cpp->latitude = latitude;
}

-(float) latitude {
    return self.cpp->latitude;
}

-(void) setRadiusFactor: (float) radiusFactor {
    self.cpp->radiusFactor = radiusFactor;
}

-(float) radiusFactor {
    return self.cpp->radiusFactor;
}

@end

@implementation SphericalCoord (Cpp)

-(hero::SphericalCoord*) cpp {
    return static_cast<hero::SphericalCoord*>(self.cppHandle);
}

@end
