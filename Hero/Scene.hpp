//
//  Scene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#pragma once

#include "apple/metal/Metal.h"

#include <vector>
#include <simd/simd.h>

namespace hero {

class Layer;
class Camera;
class RenderingContext;

class Scene {
public:
    
    Scene();
    
    inline void setBgrColor(const simd::float4& color);
    inline const simd::float4& bgrColor() const;
    
    inline void setViewportSize(const simd::float2& size);
    inline const simd::float2& viewportSize() const;
    
    inline void setSize(const simd::float2& size);
    inline const simd::float2& size() const;
    
    inline void setViewCamera(Camera* viewCamera);
    inline Camera* viewCamera() const;
    
    void addLayer(Layer* layer);
    
    void render(RenderingContext* renderingContext);
    
private:
    std::vector<Layer*> _layers;
    Camera* _viewCamera;
    simd::float4 _bgrColor = {0.f, 0.f, 0.f, 1.f};
    simd::float2 _viewportSize;
    simd::float2 _size;
    apple::metal::RenderPipelineStateRef _pipelineStateRef;
    apple::metal::BufferRef _vertexBuffer;
};

void Scene::setViewportSize(const simd::float2& size) {
    _size = size;
}

const simd::float2& Scene::viewportSize() const {
    return _size;
}

void Scene::setSize(const simd::float2& size) {
    _size = size;
}

const simd::float2& Scene::size() const {
    return _size;
}

void Scene::setBgrColor(const simd::float4& color) {
    _bgrColor = color;
}

const simd::float4& Scene::bgrColor() const {
    return _bgrColor;
}

void Scene::setViewCamera(Camera* viewCamera) {
    _viewCamera = viewCamera;
}

Camera* Scene::viewCamera() const {
    return _viewCamera;
}

}
