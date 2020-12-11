//
//  Component.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/3/20.
//

#pragma once

#include "TypeId.hpp"

#include <unordered_map>
#include <type_traits>
#include <cassert>

namespace hero {

class SceneObject;
class Component;
class CompositeComponent;

template <typename CT>
constexpr bool isConcreteComponent = std::is_base_of_v<Component, CT> && !std::is_same_v<CompositeComponent, CT>;

// MARK: Component declaration
class Component {
public:
    
    enum class State {
        new_,
        active,
        removed
    };
    
    Component(const SceneObject& sceneObject);
    
    inline bool isRemoved() const;
    inline bool isActive() const;
    
protected:
    template <typename CT>
    std::enable_if_t<isConcreteComponent<CT>, CT*> get() const;
    
    virtual void onEnter() {};
    virtual void onExit() {};
    virtual void onNewComponent(TypeId typeId, Component* component) {};
    virtual void onRemoveComponent(TypeId typeId, Component* component) {};
    
    friend class CompositeComponent;
    
private:
    virtual void enter();
    virtual void exit();
    virtual void notifyNewComponent(TypeId typeId, Component* component);
    virtual void notifyRemoveComponent(TypeId typeId, Component* component);
    
    const SceneObject& _sceneObject;
    CompositeComponent* _parent = nullptr;
    State _state = State::new_;
};

// MARK: CompositeComponent declaration
class CompositeComponent: public Component {
public:
    using Component::Component;
    
    friend class Component;
    friend class SceneObject;
    
protected:
    
    template <typename CT, typename... Args>
    std::enable_if_t<isConcreteComponent<CT>, CT*> setChild(Args&&... args);
    
    template <typename CT>
    std::enable_if_t<isConcreteComponent<CT>, void> removeChild();
    
    template <typename CT>
    std::enable_if_t<isConcreteComponent<CT>, CT*> getChild() const;
    
private:
    void enter() override;
    void exit() override;
    void notifyNewComponent(TypeId typeId, Component* component) override;
    void notifyRemoveComponent(TypeId typeId, Component* component) override;
    
    std::unordered_map<TypeId, Component*> _children;
    bool _childrenUnlocked = true;
};

// MARK: Component definition
bool Component::isRemoved() const {
    return _state == State::removed;
}

bool Component::isActive() const {
    return _state == State::active;
}

template <typename CT>
std::enable_if_t<isConcreteComponent<CT>, CT*> Component::get() const {
    auto parent = _parent;
    while (parent) {
        if (auto child = parent->getChild<CT>(); child && child != this) {
            return child;
        }
        parent = parent->_parent;
    }
    return nullptr;
}

// MARK: CompositeComponent definition
template <typename CT, typename... Args>
std::enable_if_t<isConcreteComponent<CT>, CT*> CompositeComponent::setChild(Args&&... args) {
    assert(!isRemoved());
    assert(_childrenUnlocked);
    assert(_children.find(typeIdOf<CT>) == _children.end());
    // TODO:
    auto component = new CT {_sceneObject, std::forward<Args>(args)...};
    component->_parent = this;
    _children[typeIdOf<CT>] = component;
    if (isActive()) {
        component->enter();
        notifyNewComponent(typeIdOf<CT>, component);
    }
    return component;
}

template <typename CT>
std::enable_if_t<isConcreteComponent<CT>, void> CompositeComponent::removeChild() {
    assert(!isRemoved());
    assert(_childrenUnlocked);
    auto it = _children.find(typeIdOf<CT>);
    if (it == _children.end()) {
        return;
    }
    if (isActive()) {
        notifyRemoveComponent(typeIdOf<CT>, it->second);
        it->second->exit();
    }
    _children.erase(it);
}

template <typename CT>
std::enable_if_t<isConcreteComponent<CT>, CT*> CompositeComponent::getChild() const {
    auto it = _children.find(typeIdOf<CT>);
    return it == _children.end() ? nullptr : static_cast<CT*>(it->second);
}

}
