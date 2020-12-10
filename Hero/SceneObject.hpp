//
//  SceneObject.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 9/29/20.
//

#pragma once

#include "ObjCWrappee.hpp"
#include "Transform.hpp"
#include "TypeId.hpp"

#include <unordered_map>

namespace hero {

class SceneObject: public ObjCWrappee {
public:
    
    SceneObject();
    ~SceneObject();
    
    template <typename CT>
    inline CT* set();
    
    template <typename CT>
    inline CT* get() const;
    
    static SceneObject* makeBasic();
    
private:
    std::unordered_map<TypeId, Component*> _components;
};

template <typename CT>
CT* SceneObject::set() {
    assert(_components.find(typeId<CT>) == _components.end());
    // TODO:
    auto component = new CT {*this};
    _components[typeId<CT>] = component;
    return component;
}

template <typename CT>
CT* SceneObject::get() const {
    auto it = _components.find(typeId<CT>);
    return it == _components.end() ? nullptr : static_cast<CT*>(it->second);
}

}
