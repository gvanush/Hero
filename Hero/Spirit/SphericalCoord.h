//
//  SphericalCoord.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#pragma once

#include <simd/simd.h>

typedef struct {
    simd_float3 center;
    float radius;
    float longitude; // relative to z
    float latitude; // relative to y
} spt_spherical_coord;

spt_spherical_coord spt_make_spherical_coord(void);
simd_float3 spt_position(spt_spherical_coord coord);
