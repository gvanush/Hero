//
//  Component.cpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/3/20.
//

#include "Component.hpp"
#include "SceneObject.hpp"
#include "Scene.hpp"
#include "UnownedCppWrapperRegistry.h"

namespace hero {

// MARK: Component definition
Component::Component(SceneObject& sceneObject)
: _sceneObject {sceneObject} {
}

Component::~Component() {
    UnownedCppWrapperRegistry::shared().removeWrapperFor(this);
}

Scene& Component::scene() const {
    return _sceneObject.scene();
}

void Component::start() {
    onStart();
}

void Component::stop() {
    onStop();
}

void Component::notifyNewComponent(ComponentTypeInfo typeInfo, Component* component) {
    onComponentDidAdd(typeInfo, component);
}

void Component::notifyRemovedComponent(ComponentTypeInfo typeInfo, Component* component) {
    onComponentWillRemove(typeInfo, component);
}

// MARK: CompositeComponent definition
CompositeComponent::~CompositeComponent() {
    for(const auto& item: _children) {
        const auto component = item.second;
        component->_state = ComponentState::removed;
        if (item.first.isComposite()) {
            delete component;
        } else {
            RemovedComponentRegistry::shared().addComponent(component);
        }
    }
}

void CompositeComponent::start() {
    _childrenUnlocked = false;
    for(const auto& item: _children) {
        item.second->start();
    }
    _childrenUnlocked = true;
    
    Component::start();
}

void CompositeComponent::stop() {
    Component::stop();
    
    _childrenUnlocked = false;
    for(const auto& item: _children) {
        item.second->stop();
    }
    _childrenUnlocked = true;
}

void CompositeComponent::processNewComponent(ComponentTypeInfo typeInfo, Component* component) {
    if (scene().isTurnedOn()) {
        component->start();
        notifyNewComponent(typeInfo, component);
    }
}

void CompositeComponent::notifyNewComponent(ComponentTypeInfo typeId, Component* component) {
    
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

void CompositeComponent::processRemovedComponent(ComponentTypeInfo typeInfo, Component* component) {
    if (scene().isTurnedOn()) {
        notifyRemovedComponent(typeInfo, component);
        component->stop();
    }
}

void CompositeComponent::notifyRemovedComponent(ComponentTypeInfo typeInfo, Component* component) {
    if (component->_parent != this) {
        Component::notifyRemovedComponent(typeInfo, component);
        if (_children.find(typeInfo) != _children.end()) {
            return;
        }
    }
    
    for(const auto& item: _children) {
        item.second->notifyRemovedComponent(typeInfo, component);
    }
}

}
