//
//  Component.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 12/3/20.
//

#pragma once

#include "UIRepresentable.hpp"
#include "ComponentTypeInfo.hpp"
#include "GraphicsCoreUtils.hpp"
#include "ComponentRegistry.hpp"
#include "RemovedComponentRegistry.hpp"

#include <unordered_map>
#include <type_traits>
#include <cassert>

namespace hero {

class SceneObject;
class Scene;
class Component;
class CompositeComponent;

// MARK: Component declaration
class Component: public UIRepresentable {
public:
    
    virtual ~Component() {};
    
    inline bool isRemoved() const;
    inline bool isActive() const;
    inline SceneObject& sceneObject() const;
    Scene& scene() const;
    
protected:
    
    Component(SceneObject& sceneObject);
    Component(const Component&) = delete;
    Component& operator=(const Component&) = delete;
    
    template <typename CT>
    std::enable_if_t<isConcreteComponent<CT>, CT*> get() const;
    
    virtual void onStart() {};
    virtual void onStop() {};
    virtual void onComponentDidAdd(ComponentTypeInfo typeInfo, Component* component) {};
    virtual void onComponentWillRemove(ComponentTypeInfo typeInfo, Component* component) {};
    
private:
    virtual void start();
    virtual void stop();
    virtual void notifyNewComponent(ComponentTypeInfo typeInfo, Component* component);
    virtual void notifyRemovedComponent(ComponentTypeInfo typeInfo, Component* component);
    
    friend class CompositeComponent;
    friend class SceneObject;
    
    template<typename CT, ComponentCategory CC>
    friend class _internal::ComponentRegistryImpl;
    
    SceneObject& _sceneObject;
    CompositeComponent* _parent = nullptr;
    ComponentState _state = ComponentState::active;
};

// MARK: CompositeComponent declaration
class CompositeComponent: public Component {
public:
    using Component::Component;
    ~CompositeComponent() override;
    
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
    void start() override;
    void stop() override;
    void processNewComponent(ComponentTypeInfo typeInfo, Component* component);
    void notifyNewComponent(ComponentTypeInfo typeInfo, Component* component) override;
    void processRemovedComponent(ComponentTypeInfo typeInfo, Component* component);
    void notifyRemovedComponent(ComponentTypeInfo typeInfo, Component* component) override;
    
    std::unordered_map<ComponentTypeInfo, Component*> _children;
    bool _childrenUnlocked = true;
};

// MARK: Component definition
bool Component::isRemoved() const {
    return _state == ComponentState::removed;
}

bool Component::isActive() const {
    return _state == ComponentState::active;
}

SceneObject& Component::sceneObject() const {
    return _sceneObject;
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
    
    auto typeInfo = ComponentTypeInfo::get<CT>();
    
    assert(_children.find(typeInfo) == _children.end());
    
    CT* component;
    if constexpr (isCompositeComponent<CT>) {
        component = new CT {_sceneObject, std::forward<Args>(args)...};
    } else {
        component = ComponentRegistry<CT>::shared().createCompoent(_sceneObject, std::forward<Args>(args)...);
    }
    
    component->_parent = this;
    _children[typeInfo] = component;

    processNewComponent(typeInfo, component);
    
    return component;
}

template <typename CT>
std::enable_if_t<isConcreteComponent<CT>, void> CompositeComponent::removeChild() {
    assert(!isRemoved());
    assert(_childrenUnlocked);
    
    auto typeInfo = ComponentTypeInfo::get<CT>();
    
    auto it = _children.find(typeInfo);
    if (it == _children.end()) {
        return;
    }
    auto component = it->second;
    processRemovedComponent(typeInfo, component);
    _children.erase(it);
    
    component->_state = ComponentState::removed;
    if constexpr (isCompositeComponent<CT>) {
        delete component;
    } else {
        RemovedComponentRegistry::shared().addComponent(component);
    }
}

template <typename CT>
std::enable_if_t<isConcreteComponent<CT>, CT*> CompositeComponent::getChild() const {
    auto it = _children.find(ComponentTypeInfo::get<CT>());
    return it == _children.end() ? nullptr : static_cast<CT*>(it->second);
}

}
