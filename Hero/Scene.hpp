//
//  Scene.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#pragma once

#include "UIRepresentable.hpp"
#include "GeometryUtils_Common.h"

#include "apple/metal/Metal.h"

#include <vector>
#include <simd/simd.h>

namespace hero {

class SceneObject;
class Camera;

class Scene: public UIRepresentable {
public:
    
    Scene();
    
    inline void setBgrColor(const simd::float4& color);
    inline const simd::float4& bgrColor() const;
    
    inline void setViewCamera(Camera* viewCamera);
    inline Camera* viewCamera() const;
    
    inline void setSelectedObject(SceneObject* selected);
    inline SceneObject* selectedObject() const;
    
    void addSceneObject(SceneObject* sceneObject);
    
    SceneObject* raycast(const Ray& ray) const;
    
private:
    std::vector<SceneObject*> _sceneObjects;
    Camera* _viewCamera;
    simd::float4 _bgrColor = {0.f, 0.f, 0.f, 1.f};
    SceneObject* _selectedObject = nullptr;
};

void Scene::setBgrColor(const simd::float4& color) {
    _bgrColor = color;
}

const simd::float4& Scene::bgrColor() const {
    return _bgrColor;
}

void Scene::setViewCamera(Camera* viewCamera) {
    _viewCamera = viewCamera;
}

Camera* Scene::viewCamera() const {
    return _viewCamera;
}

void Scene::setSelectedObject(SceneObject* object) {
    _selectedObject = object;
    setNeedsUIUpdate();
}

SceneObject* Scene::selectedObject() const {
    return _selectedObject;
}

}
