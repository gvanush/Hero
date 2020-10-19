//
//  Line.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#pragma once

#include "SceneObject.hpp"

#include <simd/simd.h>

namespace hero {

class RenderingContext;

class Line: public SceneObject {
public:
    
    Line(const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color);
    ~Line();
    
    inline void setPoint1(const simd::float3& p1);
    inline const simd::float3& point1() const;
    
    inline void setPoint2(const simd::float3& p2);
    inline const simd::float3& point2() const;
    
    inline void setThickness(float t);
    inline float thickness() const;
    
    inline void setColor(const simd::float4& c);
    inline const simd::float4& color() const;
    
    static void setup();
    static void render(RenderingContext& renderingContext);
    
private:
    simd::float4 _color;
    simd::float3 _point1;
    simd::float3 _point2;
    float _thickness;
};

void Line::setPoint1(const simd::float3& p1) {
    _point1 = p1;
}

const simd::float3& Line::point1() const {
    return _point1;
}

void Line::setPoint2(const simd::float3& p2) {
    _point2 = p2;
}
const simd::float3& Line::point2() const {
    return _point2;
}

void Line::setThickness(float t) {
    _thickness = t;
}

float Line::thickness() const {
    return _thickness;
}

void Line::setColor(const simd::float4& c) {
    _color = c;
}

const simd::float4& Line::color() const {
    return _color;
}

}
