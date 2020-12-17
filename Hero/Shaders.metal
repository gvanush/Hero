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

vertex BasicRasterizerData lineVS(uint vertexID [[vertex_id]],
                                  device const float3* vertices [[buffer(kVertexInputIndexVertices)]],
                                  constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]],
                                  constant float& thickness [[buffer(kVertexInputIndexThickness)]]) {
    constexpr uint kLineVertexCount = 4;
    const auto aspect = uniforms.viewportSize.x / uniforms.viewportSize.y;
    
    auto pos = float4 (vertices[vertexID], 1.f) * uniforms.projectionViewModelMatrix;
    auto normViewportPos = pos.xy / pos.w;
    normViewportPos.x *= aspect;
    
    auto otherPos = float4 (vertices[(vertexID + 1) % kLineVertexCount], 1.f) * uniforms.projectionViewModelMatrix;
    auto otherNormViewportPos = otherPos.xy / otherPos.w;
    otherNormViewportPos.x *= aspect;
    
    auto dir = normalize(otherNormViewportPos - normViewportPos);
    float2 normal (-dir.y, dir.x);
    normal *= (0.5f * thickness / min(uniforms.viewportSize.x, uniforms.viewportSize.y));
    normal.x /= aspect;
        
    BasicRasterizerData out;
    const auto side = (2 * (static_cast<int>(vertexID) / 2) - 1) * (1 - 2 * (static_cast<int>(vertexID) % 2));
//    const auto side = 2 * (static_cast<int>(vertexID) / 2) - 1;
    if(pos.w < 0.f) {
        // When 'w' is negative the resulting ndc z becomes more than 1.
        // Therefore the formula is used to compute the point on near plane.
        out.position = (pos + (-pos.z / (otherPos.z - pos.z)) * (otherPos - pos));
    } else {
        out.position = pos;
    }
    
    out.position = out.position / out.position.w + float4(normal * side, 0.f, 0.f);
    
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
                  device const ImageVertex* vertices [[buffer(kVertexInputIndexVertices)]],
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
