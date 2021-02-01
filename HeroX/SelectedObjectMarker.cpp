//
//  SelectedObjectMarker.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 1/5/21.
//

#include "SelectedObjectMarker.hpp"
#include "TextureRenderer.hpp"
#include "LineRenderer.hpp"

#include <simd/simd.h>

namespace hero {

namespace {

constexpr float kSelectionLineThickness = 5.f;
constexpr float kSelectionLineMiterLimit = 5.f;
constexpr simd::float4 kSelectionLineColor  {1.f, 204.f / 255.f, 0.f, 1.f};

}

void SelectedObjectMarker::onStart() {
    if(auto textureRenderer = get<TextureRenderer>(); textureRenderer) {
        setupSelection(textureRenderer);
    }
}

void SelectedObjectMarker::onComponentDidAdd(ComponentTypeInfo typeInfo, Component* component) {
    if (typeInfo.is<TextureRenderer>()) {
        setupSelection(static_cast<TextureRenderer*>(component));
    }
}

void SelectedObjectMarker::onComponentWillRemove(ComponentTypeInfo typeInfo, Component* component) {
    if (typeInfo.is<TextureRenderer>()) {
        removeChild<LineRenderer>();
    }
}

void SelectedObjectMarker::setupSelection(const TextureRenderer* textureRenderer) {
    using namespace simd;
    const auto& halfSize = 0.5 * textureRenderer->size();
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
