//
//  RenderingContext.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//  Copyright © 2020 Vanush Grigoryan. All rights reserved.
//

#pragma once

#include "Object.hpp"
#include "ShaderTypes.h"

#include "apple/metal/Metal.h"

#include <simd/simd.h>

namespace hero {

class RenderingContext: public Object {
public:
    
    static inline const auto device = apple::metal::createSystemDefaultDevice();
    static inline const auto library = device.newDefaultLibrary();
    static inline const auto commandQueue = device.newCommandQueue();
    static constexpr inline auto kColorPixelFormat = apple::metal::PixelFormat::bgra8Unorm;
    static constexpr inline auto kDepthPixelFormat = apple::metal::PixelFormat::depth32Float;
    
    using DrawableSizeType = simd::float2;
    
    Uniforms uniforms;
    apple::metal::RenderPassDescriptorRef renderPassDescriptor;
    apple::metal::CommandBufferRef commandBuffer;
    apple::metal::RenderCommandEncoderRef renderCommandEncoder;
};

}
