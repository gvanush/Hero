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
                  constant float2& viewportSize_ [[buffer(hero::kVertexInputIndexViewportSize)]],
                  constant float2& layerSize_ [[buffer(hero::kVertexInputIndexSize)]],
                  constant float3& position_ [[buffer(hero::kVertexInputIndexPosition)]]) {
    LayerRasterizerData out;

    float2 vertexPixelSpacePosition = position_.xy + vertices[vertexID].position * layerSize_;
    
    out.position.xy = vertexPixelSpacePosition / (viewportSize_ / 2.0);
    out.position.zw = float2(position_.z, 1.0);
    
    out.texCoord = vertices[vertexID].texCoord;
    
    return out;
}

fragment float4 layerFragmentShader(LayerRasterizerData in [[stage_in]],
                                    constant float4& color [[buffer(hero::kFragmentInputIndexColor)]],
                                    texture2d<half> texture [[ texture(hero::kFragmentInputIndexTexture) ]]) {

    constexpr sampler texSampler (mag_filter::linear, min_filter::linear);

    return color * (float4) texture.sample(texSampler, in.texCoord);
}
