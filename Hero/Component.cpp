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

void Component::notifyNewComponent(TypeId typeId, Component* component) {
    onComponentDidAdd(typeId, component);
}

void Component::notifyRemovedComponent(TypeId typeId, Component* component) {
    onComponentWillRemove(typeId, component);
}

// MARK: CompositeComponent definition
CompositeComponent::~CompositeComponent() {
    for(const auto& item: _children) {
        // TODO: TypeID based
        const auto component = item.second;
        if (component->isLeaf()) {
            component->_state = ComponentState::removed;
            RemovedComponentRegistry::shared().addComponent(component);
        } else {
            delete component;
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

void CompositeComponent::processNewComponent(TypeId typeId, Component* component) {
    if (scene().isTurnedOn()) {
        component->start();
        notifyNewComponent(typeId, component);
    }
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

void CompositeComponent::processRemovedComponent(TypeId typeId, Component* component) {
    if (scene().isTurnedOn()) {
        notifyRemovedComponent(typeId, component);
        component->stop();
    }
}

void CompositeComponent::notifyRemovedComponent(TypeId typeId, Component* component) {
    if (component->_parent != this) {
        Component::notifyRemovedComponent(typeId, component);
        if (_children.find(typeId) != _children.end()) {
            return;
        }
    }
    
    for(const auto& item: _children) {
        item.second->notifyRemovedComponent(typeId, component);
    }
}

}
