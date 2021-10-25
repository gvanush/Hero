//
//  TextureUtils.h
//  Hero
//
//  Created by Vanush Grigoryan on 8/4/20.
//

#pragma once

#include "TextureUtilsCommon.h"
#include "ShaderTypes.h"

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#include <simd/simd.h>
#include <array>

namespace hero {

id<MTLTexture> getWhiteUnitTexture();

constexpr std::size_t kTextureVertexCount = 4;
std::array<TextureVertex, kTextureVertexCount> getTextureVertices(TextureOrientation orientation);

inline simd::int2 getTextureSize(int bufferWidth, int bufferHeight, TextureOrientation orientation) {
    switch (orientation) {
        case kTextureOrientationLeft:
        case kTextureOrientationRight:
        case kTextureOrientationLeftMirrored:
        case kTextureOrientationRightMirrored:
            return simd::int2 {bufferHeight, bufferWidth};
        default:
            return simd::int2 {bufferWidth, bufferHeight};
    }
}

}
