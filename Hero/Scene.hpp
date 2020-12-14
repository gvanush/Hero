//
//  Scene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#pragma once

#include "GraphicsCoreUtils.hpp"
#include "UIRepresentable.hpp"
#include "GeometryUtils_Common.h"
#include "SceneObject.hpp"

#include "apple/metal/Metal.h"

#include <vector>
#include <simd/simd.h>

namespace hero {

class SceneObject;

class Scene: public UIRepresentable {
public:
    
    Scene();
    ~Scene();
    
    inline SceneObject* makeObject();
    SceneObject* makeLine(const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color);
    SceneObject* makeImage();
    
    inline void removeObject(SceneObject* object);
    
    inline void setBgrColor(const simd::float4& color);
    inline const simd::float4& bgrColor() const;
    
    inline SceneObject* viewCamera() const;
    
    inline void setSelectedObject(SceneObject* selected);
    inline SceneObject* selectedObject() const;
    
    SceneObject* raycast(const Ray& ray) const;
    
    inline StepNumber stepNumber() const;
    
    void step(float dt);
    
    friend class SceneObject;
    
private:
    
    std::vector<std::unique_ptr<SceneObject>> _objects;
    SceneObject* _viewCamera;
    simd::float4 _bgrColor = {0.f, 0.f, 0.f, 1.f};
    SceneObject* _selectedObject = nullptr;
    StepNumber _stepNumber = 0u;
    std::uint8_t _lastImageNumber = 0;
};

void Scene::setBgrColor(const simd::float4& color) {
    _bgrColor = color;
}

const simd::float4& Scene::bgrColor() const {
    return _bgrColor;
}

SceneObject* Scene::viewCamera() const {
    return _viewCamera;
}

void Scene::setSelectedObject(SceneObject* object) {
    _selectedObject = object;
    setNeedsUIUpdate();
}

SceneObject* Scene::selectedObject() const {
    return _selectedObject;
}

StepNumber Scene::stepNumber() const {
    return _stepNumber;
}

SceneObject* Scene::makeObject() {
    return _objects.emplace_back(new SceneObject {*this}).get();
}

void Scene::removeObject(SceneObject* object) {
    assert(object);
    assert(&object->scene() == this);
    
    auto it = std::find_if(_objects.begin(), _objects.end(), [object] (const auto& item) {
        return item.get() == object;
    });
    if (it == _objects.end()) {
        return;
    }
    _objects.erase(it);
}

}
