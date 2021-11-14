#pragma once

#include <simd/simd.h>

enum VertexInputIndex: unsigned int {
    kVertexInputIndexVertices     = 0,
    kVertexInputIndexViewportSize = 1,
    kVertexInputIndexSize = 2,
    kVertexInputIndexUniforms = 3,
    kVertexInputIndexThickness = 4,
    kVertexInputIndexMiterLimit = 5,
    kVertexInputIndexTextureSize = 6,
    kVertexInputIndexTexturePreferredTransform = 7,
};

enum FragmentInputIndex: unsigned int {
    kFragmentInputIndexColor = 0,
    kFragmentInputIndexTexture = 1,
    kFragmentInputIndexLumaTexture = 2,
    kFragmentInputIndexChromaTexture = 3,
};

struct TextureVertex {
    simd_float2 position;
    simd_float2 texCoord;
};

typedef struct {
    simd_float4x4 projectionViewMatrix;
    simd_float4x4 projectionViewModelMatrix;
    simd_float2 viewportSize;
} Uniforms;

// Buffer index values shared between shader and C code to ensure Metal shader buffer inputs
// match Metal API buffer set calls.
typedef enum AAPLVertexInputIndex
{
    AAPLVertexInputIndexVertices     = 0,
    AAPLVertexInputIndexViewportSize = 1,
} AAPLVertexInputIndex;

//  This structure defines the layout of vertices sent to the vertex
//  shader. This header is shared between the .metal shader and C code, to guarantee that
//  the layout of the vertex array in the C code matches the layout that the .metal
//  vertex shader expects.
typedef struct
{
    vector_float2 position;
    vector_float4 color;
} AAPLVertex;
