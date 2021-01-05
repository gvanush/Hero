//
//  LineRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#pragma once

#include "Component.hpp"

#include "apple/metal/Metal.h"

#include <vector>
#include <simd/simd.h>

namespace hero {

class SceneObject;
class Transform;

class LineRenderer: public Component {
public:
    
    LineRenderer(SceneObject& sceneObject, const std::vector<simd::float3>& points, float thickness = 1.f, const simd::float4& color = simd::float4 {1.f});
    
    inline const std::vector<simd::float3>& points() const;
    
    inline void setThickness(float t);
    inline float thickness() const;
    
    inline void setColor(const simd::float4& c);
    inline const simd::float4& color() const;
    
    void render(void* renderingContext);
    
    void onStart() override;
    void onStop() override;
    void onComponentWillRemove(ComponentTypeInfo typeInfo, Component*) override;
    
    static void setup();
    
    static constexpr auto category = ComponentCategory::renderer;
    
private:
    const std::vector<simd::float3> _points;
    simd::float4 _color;
    Transform* _transform = nullptr;
    void* _pointsBuffer;
    float _thickness;
};

const std::vector<simd::float3>& LineRenderer::points() const {
    return _points;
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
