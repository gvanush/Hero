//
//  LineRenderer.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 10/18/20.
//

#pragma once

#include "Renderer.hpp"

#include <vector>
#include <simd/simd.h>

namespace hero {

class SceneObject;
class Transform;

class LineRenderer: public Renderer {
public:
    
    LineRenderer(SceneObject& sceneObject, const std::vector<simd::float3>& points, bool closed = false, Layer layer = kLayerContent);
    ~LineRenderer() override;
    
    inline const std::vector<simd::float3>& points() const;
    inline bool isClosed() const;
    
    inline void setThickness(float t);
    inline float thickness() const;
    
    inline void setMiterLimit(float t);
    inline float miterLimit() const;
    
    inline void setColor(const simd::float4& c);
    inline const simd::float4& color() const;
    
    void render(void* renderingContext);
    
    void onStart() override;
    void onComponentWillRemove(ComponentTypeInfo typeInfo, Component*) override;
    
    static void setup();
    static void preRender(void* renderingContext);
    
    static constexpr auto category = ComponentCategory::renderer;
    
private:
    const std::vector<simd::float3> _points;
    simd::float4 _color {};
    Transform* _transform = nullptr;
    void* _pointsBuffer;
    float _thickness {1.f};
    float _miterLimit {1.f};
    bool _closed;
};

const std::vector<simd::float3>& LineRenderer::points() const {
    return _points;
}

bool LineRenderer::isClosed() const {
    return _closed;
}

void LineRenderer::setThickness(float t) {
    _thickness = t;
    _miterLimit = std::max(_thickness, _miterLimit);
}

float LineRenderer::thickness() const {
    return _thickness;
}

void LineRenderer::setMiterLimit(float miterLimit) {
    _miterLimit = std::max(miterLimit, _thickness);
}

float LineRenderer::miterLimit() const {
    return _miterLimit;
}

void LineRenderer::setColor(const simd::float4& c) {
    _color = c;
}

const simd::float4& LineRenderer::color() const {
    return _color;
}

}
