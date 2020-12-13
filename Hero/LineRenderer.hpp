//
//  LineRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#pragma once

#include "SceneObject.hpp"

#include <simd/simd.h>

namespace hero {

class RenderingContext;

class LineRenderer: public SceneObject {
public:
    
    LineRenderer(const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color);
    ~LineRenderer();
    
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

void LineRenderer::setPoint1(const simd::float3& p1) {
    _point1 = p1;
}

const simd::float3& LineRenderer::point1() const {
    return _point1;
}

void LineRenderer::setPoint2(const simd::float3& p2) {
    _point2 = p2;
}
const simd::float3& LineRenderer::point2() const {
    return _point2;
}

void LineRenderer::setThickness(float t) {
    _thickness = t;
}

float LineRenderer::thickness() const {
    return _thickness;
}

void LineRenderer::setColor(const simd::float4& c) {
    _color = c;
}

const simd::float4& LineRenderer::color() const {
    return _color;
}

}
