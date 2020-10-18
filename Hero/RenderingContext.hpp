//
//  RenderingContext.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#pragma once

#include "apple/metal/Metal.h"
#include "ShaderTypes.h"
#include <simd/simd.h>

namespace hero {

class RenderingContext {
public:
    
    static inline const auto device = apple::metal::createSystemDefaultDevice();
    static inline const auto library = device.newDefaultLibrary();
    static inline const auto commandQueue = device.newCommandQueue();
    static constexpr inline auto kColorPixelFormat = apple::metal::PixelFormat::bgra8Unorm;
    
    using DrawableSizeType = simd::float2;
    
    Uniforms uniforms;
    apple::metal::DrawableRef drawable;
    apple::metal::RenderPassDescriptorRef renderPassDescriptor;
    apple::metal::CommandBufferRef commandBuffer;
    simd::float2 drawableSize;
};

}
