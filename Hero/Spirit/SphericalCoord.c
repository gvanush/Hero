//
//  SphericalCoord.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#include "SphericalCoord.h"
#include "SIMDUtil.h"

spt_spherical_coord spt_make_spherical_coord(void) {
    spt_spherical_coord coord;
    coord.center = float3_zero;
    coord.radius = 1.f;
    coord.longitude = 0.f;
    coord.latitude = 0.f;
    return coord;;
}

simd_float3 spt_position(spt_spherical_coord coord) {
    float lngSin = sinf(coord.longitude);
    float lngCos = cosf(coord.longitude);
    float latSin = sinf(coord.latitude);
    float latCos = cosf(coord.latitude);
    return coord.center + coord.radius * simd_make_float3(lngSin * latSin, latCos, lngCos * latSin);

}
