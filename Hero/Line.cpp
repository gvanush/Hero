//
//  Line.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#include "Line.hpp"

namespace hero {

Line::Line(const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color)
: _color {color}
, _point1 {point1}
, _point2 {point2}
, _thickness {thickness} {
}

}
