#pragma once

#include <simd/simd.h>

namespace hero {

enum VertexInputIndex: unsigned int {
    kVertexInputIndexVertices     = 0,
    kVertexInputIndexViewportSize = 1,
    kVertexInputIndexSize = 2,
    kVertexInputIndexPosition = 3,
    kVertexInputIndexUniforms = 4,
};

enum FragmentInputIndex: unsigned int {
    kFragmentInputIndexColor = 0,
    kFragmentInputIndexTexture = 1,
};

struct LayerVertex {
    simd::float3 position;
    simd::float2 texCoord;
};

struct Uniforms {
    simd::float4x4 projectionViewMatrix;
};

}
