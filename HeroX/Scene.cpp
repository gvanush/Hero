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
#include "SelectedObjectMarker.hpp"
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
    // Stop all components
    setTurnedOn(false);
    
    // Delete all objects, this will cause all components to be removed
    for(auto object: _objects) {
        delete object;
    }
    
    // Clean renderer registry
    hero::ComponentRegistry<hero::LineRenderer>::shared().cleanComponents(this);
    hero::ComponentRegistry<hero::ImageRenderer>::shared().cleanComponents(this);
    
    // Destroy all components
    RemovedComponentRegistry::shared().destroyComponents(this);
    
    _viewCamera = nullptr;
}

void Scene::setTurnedOn(bool turnedOn) {
    if (_turnedOn == turnedOn) { return; }
    _turnedOn = turnedOn;
    
    _objectsUnlocked = false;
    if (turnedOn) {
        for(const auto& object: _objects) {
            object->start();
        }
    } else {
        for(const auto& object: _objects) {
            object->stop();
        }
    }
    _objectsUnlocked = true;
}

SceneObject* Scene::makeObject() {
    assert(_objectsUnlocked);
    auto object = *_objects.emplace(new SceneObject {*this}).first;
    if (_turnedOn) {
        object->start();
    }
    return object;
}

SceneObject* Scene::makeBasicObject() {
    auto sceneObject = makeObject();
    sceneObject->set<hero::Transform>();
    return sceneObject;
}

SceneObject* Scene::makeLine(const simd::float3& point1, const simd::float3& point2, float thickness, const simd::float4& color) {
    auto sceneObject = makeObject();
    sceneObject->set<hero::Transform>();
    auto lineRenderer = sceneObject->set<hero::LineRenderer>(std::vector<simd::float3> {point1, point2});
    lineRenderer->setThickness(thickness);
    lineRenderer->setColor(color);
    return sceneObject;
}

SceneObject* Scene::makeLineSegment(const simd::float3& point1, const simd::float3& point2, const simd::float3& point3, float thickness, const simd::float4& color) {
    auto sceneObject = makeObject();
    sceneObject->set<hero::Transform>();
    auto lineRenderer = sceneObject->set<hero::LineRenderer>(std::vector<simd::float3> {point1, point2, point3});
    lineRenderer->setThickness(thickness);
    lineRenderer->setColor(color);
    return sceneObject;
}

SceneObject* Scene::makeImage() {
    auto sceneObject = makeObject();
    
    std::ostringstream oss;
    oss << u8"Image ";
    oss << (++_lastImageNumber % 1000);
    
    sceneObject->setName(oss.str());
    sceneObject->set<hero::Transform>();
    sceneObject->set<hero::ImageRenderer>();
    return sceneObject;
}

void Scene::removeObject(SceneObject* object) {
    assert(object);
    assert(&object->scene() == this);
    assert(_objectsUnlocked);
    
    if(_selectedObject == object) {
        setSelectedObject(nullptr);
    }
    
    if (_turnedOn) {
        object->stop();
    }
    _objects.erase(object);
    delete object;
}

void Scene::setSelectedObject(SceneObject* object) {
    if (_selectedObject == object) { return; }
    if (_selectedObject) {
        _selectedObject->remove<SelectedObjectMarker>();
    }
    _selectedObject = object;
    if (_selectedObject) {
        _selectedObject->set<SelectedObjectMarker>();
    }
    setNeedsUIUpdate();
}

SceneObject* Scene::raycast(const Ray& ray) const {
    assert(_turnedOn);
    if (auto component = ComponentRegistry<ImageRenderer>::shared().raycast(this, ray); component) {
        return &component->sceneObject();
    }
    return nullptr;
}

void Scene::step(float /*dt*/) {
    assert(_turnedOn);
    
    // Update components
    //
    
    // Increase step number after update
    ++_stepNumber;
}

}
