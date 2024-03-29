//
//  Shaders.metal
//  Hero
//
//  Created by Vanush Grigoryan on 8/2/20.
//

#import "ShaderTypes.h"
#import "RenderableMaterials.h"

#include <metal_stdlib>

using namespace metal;

// MARK: Common
typedef struct {
    float4 position [[position]];
} BasicRasterizerData;

vertex BasicRasterizerData basicVS(uint vertexID [[vertex_id]],
                                   constant MeshVertex* vertices [[buffer(kVertexInputIndexVertices)]],
                                   constant float4x4& worldMatrix [[buffer(kVertexInputIndexWorldMatrix)]],
                                   constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    return BasicRasterizerData {uniforms.projectionViewMatrix * worldMatrix * float4(vertices[vertexID].position, 1.f)};
}

fragment float4 basicFS(BasicRasterizerData in [[stage_in]],
                        constant float4& color [[buffer(kFragmentInputIndexColor)]]) {
    return color;
}


// MARK: Line rendering
vertex BasicRasterizerData lineVS(uint vertexId [[vertex_id]],
                                  device const float3* vertices [[buffer(kVertexInputIndexVertices)]],
                                  constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]],
                                  constant float& thickness [[buffer(kVertexInputIndexThickness)]],
                                  constant float& miterLimit [[buffer(kVertexInputIndexMiterLimit)]]) {
    const auto aspect = uniforms.viewportSize.x / uniforms.viewportSize.y;
    
    // Extract points and convert to normalized viewport coordinates
    auto prevPoint = float4 (vertices[vertexId - 2], 1.f) /* * uniforms.projectionViewModelMatrix */;
    prevPoint.x *= aspect;
    auto point = float4 (vertices[vertexId], 1.f) /* * uniforms.projectionViewModelMatrix; */;
    point.x *= aspect;
    auto nextPoint = float4 (vertices[vertexId + 2], 1.f) /* * uniforms.projectionViewModelMatrix */;
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


// MARK: Texture rendering
typedef struct {
    float4 position [[position]];
    float2 texCoord;
} TextureRasterizerData;

vertex TextureRasterizerData
textureVS(uint vertexID [[vertex_id]],
                  device const TextureVertex* vertices [[buffer(kVertexInputIndexVertices)]],
                  constant float2& size [[buffer(kVertexInputIndexSize)]],
                  constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    TextureRasterizerData out;
//    out.position = float4 (vertices[vertexID].position * size, 0.f, 1.f) * uniforms.projectionViewModelMatrix;
//    out.texCoord = vertices[vertexID].texCoord;
    return out;
}

fragment float4 textureFS(TextureRasterizerData in [[stage_in]],
                                    constant float4& color [[buffer(kFragmentInputIndexColor)]],
                                    texture2d<half> texture [[ texture(kFragmentInputIndexTexture) ]]) {
    constexpr sampler texSampler (mag_filter::linear, min_filter::linear);
    return color * (float4) texture.sample(texSampler, in.texCoord);
}

vertex TextureRasterizerData
videoTextureVS(uint vertexID [[vertex_id]],
               device const TextureVertex* vertices [[buffer(kVertexInputIndexVertices)]],
               constant float2& size [[buffer(kVertexInputIndexSize)]],
               constant float2& textureSize [[buffer(kVertexInputIndexTextureSize)]],
               constant float2x3& texturePreferredTransform [[buffer(kVertexInputIndexTexturePreferredTransform)]],
               constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    TextureRasterizerData out;
    out.position = float4 (vertices[vertexID].position * size, 0.f, 1.f) /* * uniforms.projectionViewModelMatrix */;
    const auto transformedSize = abs(float3(textureSize, 0.f) * texturePreferredTransform).xy;
    out.texCoord = ( (float3(vertices[vertexID].texCoord * textureSize, 1.f) * texturePreferredTransform)) / transformedSize;
    return out;
}

fragment float4 videoFS(TextureRasterizerData in [[stage_in]],
                        texture2d<float, access::sample> lumaTexture [[ texture(kFragmentInputIndexLumaTexture) ]],
                        texture2d<float, access::sample> chromaTexture [[ texture(kFragmentInputIndexChromaTexture) ]]) {
    
    constexpr sampler colorSampler(mip_filter::linear,
                                   mag_filter::linear,
                                   min_filter::linear,
                                   address::repeat);
    
    const float4x4 ycbcrToRGBTransform = float4x4(
        float4(+1.0000f, +1.0000f, +1.0000f, +0.0000f),
        float4(+0.0000f, -0.3441f, +1.7720f, +0.0000f),
        float4(+1.4020f, -0.7141f, +0.0000f, +0.0000f),
        float4(-0.7010f, +0.5291f, -0.8860f, +1.0000f)
    );
    
    // Sample Y and CbCr textures to get the YCbCr color at the given texture coordinate
    float4 ycbcr = float4(lumaTexture.sample(colorSampler, in.texCoord).r,
                          chromaTexture.sample(colorSampler, in.texCoord).rg, 1.0);
    
    // Return converted RGB color
    return ycbcrToRGBTransform * ycbcr;
}


// MARK: Polyline rendering
vertex BasicRasterizerData polylineVS(uint vertexID [[vertex_id]],
                                      constant PolylineVertex* vertices [[buffer(kVertexInputIndexVertices)]],
                                      constant float4x4& worldMatrix [[buffer(kVertexInputIndexWorldMatrix)]],
                                      constant float& thickness [[buffer(kVertexInputIndexThickness)]],
                                      constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    
    // Each line segment is represented by 4 points (2 triangles)
    const auto aspect = uniforms.viewportSize.x / uniforms.viewportSize.y;
    const auto projectionViewModelMatrix = uniforms.projectionViewMatrix * worldMatrix;
    
    auto point = projectionViewModelMatrix * float4(vertices[vertexID].position, 1.0);
    point.x *= aspect;
    
    // For vertex 0 in a segment adjacent point is 2, for vertex 1 it is 3 and viceversa
    const uint adjacentVertexIndex = 2 - 4 * ((vertexID % 4) / 2) + vertexID;
    auto adjacentPoint = projectionViewModelMatrix * float4(vertices[adjacentVertexIndex].position, 1.0);
    adjacentPoint.x *= aspect;
    
    // When 'w' is negative the resulting ndc z becomes more than 1.
    // Therefore points are projected to the near plane
    if (adjacentPoint.w < 0.f) {
        adjacentPoint = adjacentPoint + (adjacentPoint.z / (adjacentPoint.z - point.z)) * (point - adjacentPoint);
    }
    
    if (point.w < 0.f) {
        point = point + (point.z / (point.z - adjacentPoint.z)) * (adjacentPoint - point);
    }
    
    // Bring to NDC space
    point /= point.w;
    adjacentPoint /= adjacentPoint.w;

    // Calculate segment normal
    const auto normDir = 1 - 2 * static_cast<int>(vertexID % 2);
    const auto norm = normDir * normalize(float2 {point.y - adjacentPoint.y, adjacentPoint.x - point.x});
    
    const auto thicknessNDCFactor = uniforms.screenScale / max(uniforms.viewportSize.x, uniforms.viewportSize.y);
    point.xy += (0.5 * thickness * thicknessNDCFactor) * norm;
    
    point.x /= aspect;
    return BasicRasterizerData {point};
}

// MARK: Arc rendering
vertex BasicRasterizerData arcVS(uint vertexID [[vertex_id]],
                                      constant ArcUniforms& arc [[buffer(kVertexInputIndexArcUniforms)]],
                                      constant float4x4& worldMatrix [[buffer(kVertexInputIndexWorldMatrix)]],
                                      constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    
    const auto aspect = uniforms.viewportSize.x / uniforms.viewportSize.y;
    const auto projectionViewModelMatrix = uniforms.projectionViewMatrix * worldMatrix;
    
    const auto pointIndex = vertexID / 2;
    const auto pointAngle = mix(arc.startAngle, arc.endAngle, static_cast<float>(pointIndex) / arc.pointCount);
    
    auto point = projectionViewModelMatrix * float4(arc.radius * cos(pointAngle), arc.radius * sin(pointAngle), 0.f, 1.f);
    point.x *= aspect;
    
    const auto adjacentPointAngle = mix(arc.startAngle, arc.endAngle, static_cast<float>(pointIndex + 1) / arc.pointCount);
    auto adjacentPoint = projectionViewModelMatrix * float4(arc.radius * cos(adjacentPointAngle), arc.radius * sin(adjacentPointAngle), 0.f, 1.f);
    adjacentPoint.x *= aspect;
    
    // When 'w' is negative the resulting ndc z becomes more than 1.
    // Therefore points are projected to the near plane
    if (adjacentPoint.w < 0.f) {
        adjacentPoint = adjacentPoint + (adjacentPoint.z / (adjacentPoint.z - point.z)) * (point - adjacentPoint);
    }
    
    if (point.w < 0.f) {
        point = point + (point.z / (point.z - adjacentPoint.z)) * (adjacentPoint - point);
    }
    
    // Bring to NDC space
    point /= point.w;
    adjacentPoint /= adjacentPoint.w;

    // Calculate segment normal
    const auto normDir = 1 - 2 * static_cast<int>(vertexID % 2);
    const auto norm = normDir * normalize(float2 {point.y - adjacentPoint.y, adjacentPoint.x - point.x});
    
    const auto thicknessNDCFactor = uniforms.screenScale / max(uniforms.viewportSize.x, uniforms.viewportSize.y);
    point.xy += (0.5 * arc.thickness * thicknessNDCFactor) * norm;
    
    point.x /= aspect;
    return BasicRasterizerData {point};
}

// MARK: Point rendering
typedef struct {
    float4 position [[position]];
    float2 fragCoord;
} PointRasterizerData;

vertex PointRasterizerData pointVS(uint vertexID [[vertex_id]],
                                   constant PointVertex* vertices [[buffer(kVertexInputIndexVertices)]],
                                   constant float& size [[buffer(kVertexInputIndexSize)]],
                                   constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    
    auto point = uniforms.projectionViewMatrix * float4(vertices[vertexID].position, 1.0);
    
    // Bring to NDC space
    const auto aspect = uniforms.viewportSize.x / uniforms.viewportSize.y;
    point.x *= aspect;
    point /= point.w;
    
    // Adjust
    const auto ndcSize = size * uniforms.screenScale / max(uniforms.viewportSize.x, uniforms.viewportSize.y);
    point.x += (2 * static_cast<int>(vertexID % 2) - 1) * ndcSize;
    point.y += (2 * static_cast<int>(vertexID / 2) - 1) * ndcSize;
    
    point.x /= aspect;
    return PointRasterizerData {point, vertices[vertexID].fragCoord};
}

fragment float4 pointFS(PointRasterizerData in [[stage_in]],
                        constant float4& color [[buffer(kFragmentInputIndexColor)]]) {
    if(dot(in.fragCoord, in.fragCoord) > 1.f) {
        discard_fragment();
    }
    return color;
}


// MARK: Outline rendering
vertex BasicRasterizerData outlineVS(uint vertexID [[vertex_id]],
                                     constant MeshVertex* vertices [[buffer(kVertexInputIndexVertices)]],
                                     constant float4x4& worldMatrix [[buffer(kVertexInputIndexWorldMatrix)]],
                                     constant float4x4& transposedInverseWorldMatrix [[buffer(kVertexInputIndexTransposedInverseWorldMatrix)]],
                                     constant float& thickness [[buffer(kVertexInputIndexThickness)]],
                                     constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    

    auto point = worldMatrix * float4(vertices[vertexID].position, 1.0);
    auto normal = transposedInverseWorldMatrix * float4(vertices[vertexID].adjacentSurfaceNormalAverage, 0.0);
    normal.w = 0.0;
    
    auto nPoint = uniforms.projectionViewMatrix * (point + normal);
    point = uniforms.projectionViewMatrix * point;
    
    // Bring to NDC
    const auto aspect = uniforms.viewportSize.x / uniforms.viewportSize.y;
    point.x *= aspect;
    const auto pw = point.w;
    point /= point.w;
    nPoint.x *= aspect;
    nPoint /= nPoint.w;
    
    const auto thicknessNDCFactor = uniforms.screenScale / max(uniforms.viewportSize.x, uniforms.viewportSize.y);
    
    auto fp = float4(point.xy + (thickness * thicknessNDCFactor) * normalize(nPoint.xy - point.xy), point.z, 1.f);
    fp.x /= aspect;
    fp *= pw;
    
    return BasicRasterizerData {fp};
}

// MARK: Mesh rendering
struct MeshRasterizerData {
    float4 position [[position]];
    float3 fragWorldPosition;
    float3 normal;
};

vertex MeshRasterizerData meshVS(uint vertexID [[vertex_id]],
                                 constant MeshVertex* vertices [[buffer(kVertexInputIndexVertices)]],
                                 constant float4x4& worldMatrix [[buffer(kVertexInputIndexWorldMatrix)]],
                                 constant float4x4& transposedInverseWorldMatrix [[buffer(kVertexInputIndexTransposedInverseWorldMatrix)]],
                                 constant Uniforms& uniforms [[buffer(kVertexInputIndexUniforms)]]) {
    MeshRasterizerData out;
    const auto worldPos = worldMatrix * float4(vertices[vertexID].position, 1.f);
    out.position = uniforms.projectionViewMatrix * worldPos;
    out.fragWorldPosition = worldPos.xyz;
    out.normal = normalize((transposedInverseWorldMatrix * float4(vertices[vertexID].surfaceNormal, 0.f)).xyz);
    return out;
}

fragment float4 blinnPhongFS(MeshRasterizerData in [[stage_in]],
                             constant Uniforms& uniforms [[buffer(kFragmentInputIndexUniforms)]],
                             constant spt::PhongRenderableMaterial& material [[buffer(kFragmentInputIndexMaterial)]]) {
    constexpr float3 ambientLightColor = {0.3f, 0.3f, 0.3f};
    constexpr float3 lightColor = {0.7f, 0.7f, 0.7f};
    const float3 lightDirection = normalize(-float3 {0.8f, 1.2f, 1.f});
    
    const auto fragNormal = normalize(in.normal);
    const auto diffuseFactor = max(0.f, dot(-lightDirection, fragNormal));
    const auto diffuse = diffuseFactor * lightColor;
    
    const auto viewDir = normalize(uniforms.cameraPosition - in.fragWorldPosition);
    const auto reflectDir = reflect(lightDirection, fragNormal);
    const auto specularFactor = pow(max(dot(viewDir, reflectDir), 0.f), 63.f * material.shininess + 1.f);
    const auto specular = specularFactor * lightColor;
    
    return float4 ((ambientLightColor + diffuse) * material.color.xyz + material.shininess * specular, 1.f);
}
