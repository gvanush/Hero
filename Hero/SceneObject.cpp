//
//  SceneObject.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#include "SceneObject.hpp"
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

}
