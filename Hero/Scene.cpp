//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#include "Scene.hpp"
#include "Layer.hpp"

#include <array>
#include <iostream>

namespace hero {

Scene::Scene() {
    
}

void Scene::addSceneObject(SceneObject* sceneObject) {
    _sceneObjects.push_back(sceneObject);
}

SceneObject* Scene::raycast(const Ray& ray) const {
    return Layer::raycast(ray);
}

}
