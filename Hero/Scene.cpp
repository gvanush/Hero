//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#include "Scene.hpp"
#include "SceneObject.hpp"
#include "Camera.hpp"
#include "Transform.hpp"

#include <array>
#include <iostream>

namespace hero {

Scene::Scene() {
    _viewCamera = createObject();
    _viewCamera->set<Transform>();
    _viewCamera->set<Camera>(0.01f, 1000.f, 1.f);
}

Scene::~Scene() {
    // This causes all components to exit and be removed
    _objects.clear();
    // TODO:
//    RemovedComponentRegistry::destroyAllComponents(*this)
}

SceneObject* Scene::raycast(const Ray& ray) const {
    // TODO
//    return ImageRenderer::raycast(ray);
    return nullptr;
}

void Scene::step(float /*dt*/) {
    // Update components
    //
    
    // Increase step number after update
    ++_stepNumber;
}

}
