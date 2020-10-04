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
    float2 texCoord;
} LayerRasterizerData;

vertex LayerRasterizerData
layerVertexShader(uint vertexID [[vertex_id]],
                  device const hero::LayerVertex* vertices [[buffer(hero::kVertexInputIndexVertices)]],
                  constant float2& layerSize [[buffer(hero::kVertexInputIndexSize)]],
                  constant float3& position [[buffer(hero::kVertexInputIndexPosition)]],
                  constant hero::Uniforms& uniforms [[buffer(hero::kVertexInputIndexUniforms)]]) {
    LayerRasterizerData out;

    float4 pos = float4 {position.x, position.y, position.z, 1.f};
    pos.xy += vertices[vertexID].position.xy * layerSize;
    pos.z += vertices[vertexID].position.z;
    out.position = pos * uniforms.projectionViewMatrix;
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 layerFragmentShader(LayerRasterizerData in [[stage_in]],
                                    constant float4& color [[buffer(hero::kFragmentInputIndexColor)]],
                                    texture2d<half> texture [[ texture(hero::kFragmentInputIndexTexture) ]]) {

    constexpr sampler texSampler (mag_filter::linear, min_filter::linear);

    return color * (float4) texture.sample(texSampler, in.texCoord);
}
