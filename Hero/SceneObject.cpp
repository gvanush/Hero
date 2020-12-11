//
//  SceneObject.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#include "SceneObject.hpp"
#include "Transform.hpp"
#include "Camera.hpp"
#include "Math.hpp"

namespace hero {

SceneObject::SceneObject()
: _compositeComponent {*this} {
    // TODO:
    _compositeComponent.enter();
    
    // TODO: Remove this
    set<Transform>();
}

SceneObject::~SceneObject() {
    // TODO: Remove this
    delete get<Transform>();
}

SceneObject* SceneObject::makeBasic() {
    auto sceneObject = new SceneObject {};
    sceneObject->set<Transform>();
    return sceneObject;
}

SceneObject* SceneObject::makeCamera() {
    auto sceneObject = new SceneObject {};
    // TODO: uncomment after removing from constructor
//    sceneObject->set<Transform>();
    sceneObject->set<Camera>(0.01f, 1000.f, 1.f);
    return sceneObject;
}

}
