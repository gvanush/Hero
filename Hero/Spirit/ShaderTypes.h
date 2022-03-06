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
    kVertexInputIndexWorldMatrix = 8,
    kVertexInputIndexTransposedInverseWorldMatrix = 9,
};

enum FragmentInputIndex: unsigned int {
    kFragmentInputIndexColor = 0,
    kFragmentInputIndexTexture = 1,
    kFragmentInputIndexLumaTexture = 2,
    kFragmentInputIndexChromaTexture = 3,
    kFragmentInputIndexUniforms = 4,
    kFragmentInputIndexMaterial = 5,
};

struct TextureVertex {
    simd_float2 position;
    simd_float2 texCoord;
};

struct Uniforms {
    simd_float4x4 projectionViewMatrix;
    simd_float3 cameraPosition;
    simd_float2 viewportSize;
    float screenScale;
};

struct MeshVertex {
    using Index = uint16_t;
    simd_float3 position;
    simd_float3 surfaceNormal;
    simd_float3 adjacentSurfaceNormalAverage;
};

struct PolylineVertex {
    using Index = uint16_t;
    simd_float3 position;
};

struct PointVertex {
    simd_float3 position;
    simd_float2 fragCoord;
};
