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
#include "LineRenderer.hpp"
#include "ImageRenderer.hpp"
#include "ComponentRegistry.hpp"

#include <array>
#include <sstream>

namespace hero {

Scene::Scene() {
    _viewCamera = makeObject();
    _viewCamera->set<Transform>();
    _viewCamera->set<Camera>(0.01f, 1000.f, 1.f);
}

Scene::~Scene() {
    // This causes all components to exit and be removed
    _objects.clear();
    // TODO:
//    RemovedComponentRegistry::destroyAllComponents(*this)
}

SceneObject* Scene::makeLine(const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color) {
    auto sceneObject = makeObject();
    sceneObject->set<hero::Transform>();
    sceneObject->set<hero::LineRenderer>(point1, point2, thickness, color);
    return sceneObject;
}

SceneObject* Scene::makeImage() {
    auto sceneObject = makeObject();
    
    std::ostringstream oss;
    oss << "Image ";
    oss << (++_lastImageNumber % 1000);
    
    sceneObject->setName(oss.str());
    sceneObject->set<hero::Transform>();
    sceneObject->set<hero::ImageRenderer>();
    return sceneObject;
}

SceneObject* Scene::raycast(const Ray& ray) const {
    if (auto component = ComponentRegistry<ImageRenderer>::shared().raycast(ray); component) {
        return &component->sceneObject();
    }
    return nullptr;
}

void Scene::step(float /*dt*/) {
    // Update components
    //
    
    // Increase step number after update
    ++_stepNumber;
}

}
