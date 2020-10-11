//
//  SphericalCoord.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/3/20.
//

#include "SphericalCoord.hpp"

namespace hero {

simd::float3 SphericalCoord::getPosition() const {
    const auto lngSin = sinf(longitude);
    const auto lngCos = cosf(longitude);
    const auto latSin = sinf(latitude);
    const auto latCos = cosf(latitude);
    return center + radiusFactor * radius * simd::float3 {lngSin * latSin, latCos, lngCos * latSin};
}

}
