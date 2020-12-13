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

#include "apple/metal/Metal.h"

#include <vector>
#include <unordered_map>
#include <simd/simd.h>

namespace hero {

class SceneObject;
class Camera;

class Scene: public UIRepresentable {
public:
    
    Scene();
    ~Scene();
    
    inline void setBgrColor(const simd::float4& color);
    inline const simd::float4& bgrColor() const;
    
    inline SceneObject* viewCamera() const;
    
    inline void setSelectedObject(SceneObject* selected);
    inline SceneObject* selectedObject() const;
    
    void addSceneObject(SceneObject* sceneObject);
    
    SceneObject* raycast(const Ray& ray) const;
    
    inline StepNumber stepNumber() const;
    
    void step(float dt);
    
private:
    std::vector<SceneObject*> _sceneObjects;
    
    SceneObject* _viewCamera;
    simd::float4 _bgrColor = {0.f, 0.f, 0.f, 1.f};
    SceneObject* _selectedObject = nullptr;
    StepNumber _stepNumber = 0u;
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

}
