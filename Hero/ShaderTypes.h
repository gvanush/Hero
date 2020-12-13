#pragma once

#include <simd/simd.h>

namespace hero {

enum VertexInputIndex: unsigned int {
    kVertexInputIndexVertices     = 0,
    kVertexInputIndexViewportSize = 1,
    kVertexInputIndexSize = 2,
    kVertexInputIndexUniforms = 3,
    kVertexInputIndexThickness = 4,
};

enum FragmentInputIndex: unsigned int {
    kFragmentInputIndexColor = 0,
    kFragmentInputIndexTexture = 1,
};

struct ImageVertex {
    simd::float2 position;
    simd::float2 texCoord;
};

struct Uniforms {
    simd::float4x4 projectionViewMatrix;
    simd::float4x4 projectionViewModelMatrix;
    simd::float2 viewportSize;
};

}
