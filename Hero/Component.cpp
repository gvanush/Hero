//
//  Component.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/3/20.
//

#include "Component.hpp"

namespace hero {

// MARK: Component definition
Component::Component(const SceneObject& sceneObject)
: _sceneObject {sceneObject} {
}

void Component::enter() {
    _state = ComponentState::active;
    onEnter();
}

void Component::exit() {
    onExit();
    _state = ComponentState::removed;
}

void Component::notifyNewComponent(TypeId typeId, Component* component) {
    onNewComponent(typeId, component);
}

void Component::notifyRemoveComponent(TypeId typeId, Component* component) {
    onRemoveComponent(typeId, component);
}

// MARK: CompositeComponent definition
void CompositeComponent::enter() {
    _childrenUnlocked = false;
    for(const auto& item: _children) {
        item.second->enter();
    }
    _childrenUnlocked = true;
    
    Component::enter();
}

void CompositeComponent::exit() {
    Component::exit();
    
    _childrenUnlocked = false;
    for(const auto& item: _children) {
        item.second->exit();
    }
    _childrenUnlocked = true;
}

void CompositeComponent::notifyNewComponent(TypeId typeId, Component* component) {
    
    if (component->_parent != this) {
        Component::notifyNewComponent(typeId, component);
        if (_children.find(typeId) != _children.end()) {
            return;
        }
    }
    
    for(const auto& item: _children) {
        if (item.second != component) {
            item.second->notifyNewComponent(typeId, component);
        }
    }
}

void CompositeComponent::notifyRemoveComponent(TypeId typeId, Component* component) {
    if (component->_parent != this) {
        Component::notifyRemoveComponent(typeId, component);
        if (_children.find(typeId) != _children.end()) {
            return;
        }
    }
    
    for(const auto& item: _children) {
        item.second->notifyRemoveComponent(typeId, component);
    }
}

}
