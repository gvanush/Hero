#pragma once

#include <simd/simd.h>

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
    simd_float2 position;
    simd_float2 texCoord;
};

typedef struct {
    simd_float4x4 projectionViewMatrix;
    simd_float4x4 projectionViewModelMatrix;
    simd_float2 viewportSize;
} Uniforms;
