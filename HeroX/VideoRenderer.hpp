//
//  VideoRenderer.hpp
//  HeroX
//
//  Created by Vanush Grigoryan on 2/4/21.
//

#pragma once

#include "Renderer.hpp"
#include "VideoPlayerProxy.h"

namespace hero {

class Transform;

class VideoRenderer: public Renderer {
public:
    
    using Renderer::Renderer;
    
    inline void setSize(const simd::float2& size);
    inline const simd::float2& size() const;
    
    inline void setVideoPlayerProxy(VideoPlayerProxy proxy);
    inline VideoPlayerProxy videoPlayerProxy() const;
    
    void render(void* renderingContext);
    
    bool raycast(const Ray& ray, float& normDistance);
    
    void onStart() override;
    void onComponentWillRemove(ComponentTypeInfo typeInfo, Component*) override;
    
    static void setup();
    static void preRender(void* renderingContext);
    
    static constexpr auto category = ComponentCategory::renderer;
    
private:
    simd::float2 _size {1.f, 1.f};
    VideoPlayerProxy _videoPlayerProxy;
    Transform* _transform = nullptr;
};

void VideoRenderer::setSize(const simd::float2& size) {
    _size = size;
}

const simd::float2& VideoRenderer::size() const {
    return _size;
}

void VideoRenderer::setVideoPlayerProxy(VideoPlayerProxy proxy) {
    _videoPlayerProxy = proxy;
}

VideoPlayerProxy VideoRenderer::videoPlayerProxy() const {
    return _videoPlayerProxy;
}

}
