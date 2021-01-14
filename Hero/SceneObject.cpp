//
//  SceneObject.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#include "SceneObject.hpp"
#include "Transform.hpp"
#include "Camera.hpp"
#include "SelectedObjectMarker.hpp"
#include "Math.hpp"

namespace hero {

SceneObject::SceneObject(Scene& scene)
: _compositeComponent {*this}
, _scene {scene} {
}

SceneObject::~SceneObject() {
    _compositeComponent._state = ComponentState::removed;
}

bool SceneObject::isSelected() const {
    return _compositeComponent.getChild<SelectedObjectMarker>();
}

}
