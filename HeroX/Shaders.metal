//
//  Shaders.metal
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//

#import "ShaderTypes.h"

#include <metal_stdlib>

using namespace metal;

typedef struct {
    float4 position [[position]];
} BasicRasterizerData;

//constant constexpr uint kSegmentVertexCount = 4;
//constant constexpr int kSegmentVertexSides[kSegmentVertexCount] = {1, -1, -1, 1};

vertex BasicRasterizerData lineVS(uint vertexId [[vertex_id]],
                                  device const float3* vertices [[buffer(kVertexInputIndexVertices)]],
                                  constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]],
                                  constant float& thickness [[buffer(kVertexInputIndexThickness)]],
                                  constant float& miterLimit [[buffer(kVertexInputIndexMiterLimit)]]) {
    const auto aspect = uniforms.viewportSize.x / uniforms.viewportSize.y;
    
    // Extract points and convert to normalized viewport coordinates
    auto prevPoint = float4 (vertices[vertexId - 2], 1.f) * uniforms.projectionViewModelMatrix;
    prevPoint.x *= aspect;
    auto point = float4 (vertices[vertexId], 1.f) * uniforms.projectionViewModelMatrix;
    point.x *= aspect;
    auto nextPoint = float4 (vertices[vertexId + 2], 1.f) * uniforms.projectionViewModelMatrix;
    nextPoint.x *= aspect;
    
    // When 'w' is negative the resulting ndc z becomes more than 1.
    // Therefore points are projected to the near plane
    if (prevPoint.w < 0.f) {
        prevPoint = prevPoint + (prevPoint.z / (prevPoint.z - point.z)) * (point - prevPoint);
    }
    
    if (point.w < 0.f) {
        point = point + (point.z / (point.z - nextPoint.z)) * (nextPoint - point);
    }
    
    if (nextPoint.w < 0.f) {
        nextPoint = nextPoint + (nextPoint.z / (nextPoint.z - point.z)) * (point - nextPoint);
    }
    
    // Bring to NDC space
    prevPoint /= prevPoint.w;
    point /= point.w;
    nextPoint /= nextPoint.w;
    
    // Compute params in NDC space
    const auto minSize = min(uniforms.viewportSize.x, uniforms.viewportSize.y);
    const auto halfThickness = 0.5f * thickness / minSize;
    const auto normMiterLimit = miterLimit / minSize;
    
    // Compute bissector of two segments
    const auto v1 = normalize(prevPoint.xy - point.xy);
    const auto v2 = normalize(nextPoint.xy - point.xy);
    auto bissector = 0.5 * (v1 + v2);
    
    if (length_squared(bissector) < 0.001) {
        bissector = float2(-v1.y, v1.x);
    } else {
        bissector = normalize(bissector);
    }
    
    // Compute miter
    const auto sine = length(cross(float3(bissector, 0.f), float3(v2, 0.f)));
    const auto miterSide = (1 - 2 * (static_cast<int>(vertexId) % 2)) * sign(dot(bissector, float2(-v2.y, v2.x)));
    const auto miter = min(halfThickness / sine, normMiterLimit);
    
    BasicRasterizerData out;
    
    out.position = float4(point.xy + miterSide * miter * bissector, point.z, 1.f);
    out.position.x /= aspect;
    
    return out;
    
}


fragment float4 uniformColorFS(constant float4& color [[buffer(kFragmentInputIndexColor)]]) {
    return color;
}

typedef struct {
    float4 position [[position]];
    float2 texCoord;
} LayerRasterizerData;

vertex LayerRasterizerData
layerVertexShader(uint vertexID [[vertex_id]],
                  device const TextureVertex* vertices [[buffer(kVertexInputIndexVertices)]],
                  constant float2& layerSize [[buffer(kVertexInputIndexSize)]],
                  constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    LayerRasterizerData out;
    out.position = float4 (vertices[vertexID].position.xy * layerSize, 0.f, 1.f) * uniforms.projectionViewModelMatrix;
    out.texCoord = vertices[vertexID].texCoord;
    return out;
}

fragment float4 layerFragmentShader(LayerRasterizerData in [[stage_in]],
                                    constant float4& color [[buffer(kFragmentInputIndexColor)]],
                                    texture2d<half> texture [[ texture(kFragmentInputIndexTexture) ]]) {
    constexpr sampler texSampler (mag_filter::linear, min_filter::linear);
    return color * (float4) texture.sample(texSampler, in.texCoord);
}
