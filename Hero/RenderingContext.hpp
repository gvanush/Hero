//
//  RenderingContext.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#pragma once

#include "apple/metal/Metal.h"

#include <simd/simd.h>

namespace hero {

class RenderingContext {
public:
    
    static inline auto device = apple::metal::createSystemDefaultDevice();
    static inline auto library = device.newDefaultLibrary();
    static inline auto commandQueue = device.newCommandQueue();
    static constexpr inline auto kColorPixelFormat = apple::metal::PixelFormat::bgra8Unorm;
    
    using DrawableSizeType = simd::float2;
    
    inline void setDrawable(const apple::metal::DrawableRef& drawable);
    inline const apple::metal::DrawableRef& drawable() const;
    
    inline void setDrawableSize(const DrawableSizeType& ds);
    inline const DrawableSizeType& drawableSize() const;
    
    inline void setRenderpassDescriptor(const apple::metal::RenderPassDescriptorRef& rpd);
    inline const apple::metal::RenderPassDescriptorRef& renderpassDescriptor() const;
    
private:
    apple::metal::DrawableRef _drawable;
    apple::metal::RenderPassDescriptorRef _renderPassDescriptor;
    simd::float2 _drawableSize;
};

void RenderingContext::setDrawable(const apple::metal::DrawableRef& drawable) {
    _drawable = drawable;
}

const apple::metal::DrawableRef& RenderingContext::drawable() const {
    return _drawable;
}

void RenderingContext::setDrawableSize(const DrawableSizeType& ds) {
    _drawableSize = ds;
}

const RenderingContext::DrawableSizeType& RenderingContext::drawableSize() const {
    return _drawableSize;
}

void RenderingContext::setRenderpassDescriptor(const apple::metal::RenderPassDescriptorRef& rpd) {
    _renderPassDescriptor = rpd;
}

const apple::metal::RenderPassDescriptorRef& RenderingContext::renderpassDescriptor() const {
    return _renderPassDescriptor;
}

}
