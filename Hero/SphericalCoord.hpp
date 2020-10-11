//
//  SphericalCoord.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#pragma once

#include <simd/simd.h>

namespace hero {

struct SphericalCoord {
    simd::float3 center {};
    float radius = 1.f;
    float longitude = 0.f; // relative to z
    float latitude = 0.f; // relative to y
    float radiusFactor = 1.f;
    simd::float3 getPosition() const;
    
};

}
