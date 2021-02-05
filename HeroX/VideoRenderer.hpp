//
//  VideoRenderer.hpp
//  HeroX
//
//  Created by Vanush Grigoryan on 2/4/21.
//

#pragma once

#include "Renderer.hpp"
#include "MaterialProxy.h"

namespace hero {

class Transform;

class VideoRenderer: public Renderer {
public:
    
    using Renderer::Renderer;
    
    inline void setSize(const simd::float2& size);
    inline const simd::float2& size() const;
    
    void setMaterialProxy(VideoMaterialProxy proxy);
    inline VideoMaterialProxy materialProxy() const;
    
    void render(void* renderingContext);
    
    void onStart() override;
    void onComponentWillRemove(ComponentTypeInfo typeInfo, Component*) override;
    
    static void setup();
    static void preRender(void* renderingContext);
    
    static constexpr auto category = ComponentCategory::renderer;
    
private:
    simd::float2 _size {1.f, 1.f};
    VideoMaterialProxy _materialProxy;
    Transform* _transform = nullptr;
};

void VideoRenderer::setSize(const simd::float2& size) {
    _size = size;
}

const simd::float2& VideoRenderer::size() const {
    return _size;
}

VideoMaterialProxy VideoRenderer::materialProxy() const {
    return _materialProxy;
}

}
