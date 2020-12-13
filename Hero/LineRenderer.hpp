//
//  LineRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#pragma once

#include "Component.hpp"

#include "apple/metal/Metal.h"

#include <simd/simd.h>

namespace hero {

class SceneObject;
class Transform;
class RenderingContext;

class LineRenderer: public Component {
public:
    
    LineRenderer(const SceneObject& sceneObject, const simd::float3& point1, const simd::float3& point2, float thickness = 1.f, const simd::float4& color = simd::float4 {1.f});
    
    inline const simd::float3& point1() const;
    
    inline const simd::float3& point2() const;
    
    inline void setThickness(float t);
    inline float thickness() const;
    
    inline void setColor(const simd::float4& c);
    inline const simd::float4& color() const;
    
    void render(RenderingContext& renderingContext);
    
    void onEnter() override;
    void onRemoveComponent(TypeId typeId, Component*) override;
    
    static void setup();
    
    static constexpr auto category = ComponentCategory::renderer;
    
private:
    static apple::metal::RenderPipelineStateRef _pipelineStateRef;
    
    simd::float4 _color;
    simd::float3 _point1;
    simd::float3 _point2;
    Transform* _transform = nullptr;
    float _thickness;
};

const simd::float3& LineRenderer::point1() const {
    return _point1;
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
