//
//  Scene.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 7/29/20.
//

#include "Scene.hpp"

#include <array>
#include <iostream>

namespace hero {

Scene::Scene() {
    
}

void Scene::addSceneObject(SceneObject* sceneObject) {
    _sceneObjects.push_back(sceneObject);
}

SceneObject* Scene::raycast() const {
    if(_sceneObjects.empty()) {
        return  nullptr;
    }
    static size_t index = 0;
    return _sceneObjects[(index++) % _sceneObjects.size()];
}

}
