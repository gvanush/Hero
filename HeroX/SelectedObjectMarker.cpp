//
//  SelectedObjectMarker.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 1/5/21.
//

#include "SelectedObjectMarker.hpp"
#include "TextureRenderer.hpp"
#include "VideoRenderer.hpp"
#include "LineRenderer.hpp"

#include <simd/simd.h>

namespace hero {

namespace {

constexpr float kSelectionLineThickness = 6.f;
constexpr float kSelectionLineMiterLimit = 5.f;
//constexpr simd::float4 kSelectionLineColor  {255.f / 255.f, 187.f / 255.f, 51.f / 255.f, 1.f}; // dark
//constexpr simd::float4 kSelectionLineColor  {255.f / 255.f, 200.f / 255.f, 89.f / 255.f, 1.f}; // light
constexpr simd::float4 kSelectionLineColor  {255.f / 255.f, 160.f / 255.f, 40.f / 255.f, 1.f}; // dark
}

void SelectedObjectMarker::onStart() {
    if(auto textureRenderer = get<TextureRenderer>(); textureRenderer) {
        setupSelection(textureRenderer);
    }
    if(auto videoRenderer = get<VideoRenderer>(); videoRenderer) {
        setupSelection(videoRenderer);
    }
}

void SelectedObjectMarker::onComponentDidAdd(ComponentTypeInfo typeInfo, Component* component) {
    if (typeInfo.is<TextureRenderer>()) {
        setupSelection(static_cast<TextureRenderer*>(component));
    }
    if (typeInfo.is<VideoRenderer>()) {
        setupSelection(static_cast<VideoRenderer*>(component));
    }
}

void SelectedObjectMarker::onComponentWillRemove(ComponentTypeInfo typeInfo, Component* component) {
    if (typeInfo.is<TextureRenderer>() || typeInfo.is<VideoRenderer>()) {
        removeChild<LineRenderer>();
    }
}

template <typename RT>
void SelectedObjectMarker::setupSelection(const RT* renderer) {
    using namespace simd;
    const auto& halfSize = 0.5 * renderer->size();
    std::vector<float3> points {
        float3 {-halfSize.x, -halfSize.y, 0.0},
        float3 {-halfSize.x, halfSize.y, 0.0},
        float3 {halfSize.x, halfSize.y, 0.0},
        float3 {halfSize.x, -halfSize.y, 0.0},
    };
    
    auto lineRenderer = setChild<LineRenderer>(points, true, kLayerUI);
    lineRenderer->setColor(kSelectionLineColor);
    lineRenderer->setThickness(kSelectionLineThickness);
    lineRenderer->setMiterLimit(kSelectionLineMiterLimit);
}

}
