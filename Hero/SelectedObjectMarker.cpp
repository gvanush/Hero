//
//  SelectedObjectMarker.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 1/5/21.
//

#include "SelectedObjectMarker.hpp"
#include "ImageRenderer.hpp"
#include "LineRenderer.hpp"

#include <simd/simd.h>

namespace hero {

namespace {

constexpr float kSelectionThickness = 5.f;
constexpr simd::float4 kSelectionColor  {1.f, 204.f / 255.f, 0.f, 1.f};

}

void SelectedObjectMarker::onStart() {
    if(auto imageRenderer = get<ImageRenderer>(); imageRenderer) {
        setupSelection(imageRenderer);
    }
}

void SelectedObjectMarker::onComponentDidAdd(ComponentTypeInfo typeInfo, Component* component) {
    if (typeInfo.is<ImageRenderer>()) {
        setupSelection(static_cast<ImageRenderer*>(component));
    }
}

void SelectedObjectMarker::onComponentWillRemove(ComponentTypeInfo typeInfo, Component* component) {
    if (typeInfo.is<ImageRenderer>()) {
        removeChild<LineRenderer>();
    }
}

void SelectedObjectMarker::setupSelection(const ImageRenderer* imageRenderer) {
    using namespace simd;
    const auto& halfSize = 0.5 * imageRenderer->size();
    std::vector<float3> points {
        float3 {-halfSize.x, -halfSize.y, 0.0},
        float3 {-halfSize.x, halfSize.y, 0.0},
        float3 {halfSize.x, halfSize.y, 0.0},
        float3 {halfSize.x, -halfSize.y, 0.0},
        float3 {-halfSize.x, -halfSize.y, 0.0},
    };
    setChild<LineRenderer>(points, kSelectionThickness, kSelectionColor, kLayerUI);
}

}
