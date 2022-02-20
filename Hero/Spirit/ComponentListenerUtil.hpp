//
//  ComponentListenerUtil.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 23.12.21.
//

#pragma once

#include "Base.h"
#include "Base.hpp"
#include "Scene.hpp"

namespace spt {

template <typename CT>
inline void addComponentWillChangeListener(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    assert(listener && callback);
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    if(auto observable = registry.try_get<Observable<CT>>(object.entity)) {
        observable->willChangeListeners.emplace_back(spt::ComponentListenerItem {listener, callback});
    } else {
        registry.emplace<Observable<CT>>(object.entity, Observable<CT>{ {spt::ComponentListenerItem{listener, callback}} });
    }
}

template <typename CT>
inline void removeComponentWillChangeListenerCallback(SPTObject object, SPTComponentListener listener, SPTComponentListenerCallback callback) {
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    if(!registry.valid(object.entity)) {
        return;
    }
    if(auto observable = registry.try_get<Observable<CT>>(object.entity)) {
        auto& listeners = observable->willChangeListeners;
        auto fit = std::find_if(listeners.begin(), listeners.end(), [listener, callback] (const auto& item) {
            return item.listener == listener && item.callback == callback;
        });
        if(fit != listeners.end()) {
            listeners.erase(fit);
        }
        if(listeners.empty()) {
            registry.erase<Observable<CT>>(object.entity);
        }
    }
}

template <typename CT>
inline void removeComponentWillChangeListener(SPTObject object, SPTComponentListener listener) {
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    if(!registry.valid(object.entity)) {
        return;
    }
    if(auto observable = registry.try_get<Observable<CT>>(object.entity)) {
        auto& listeners = observable->willChangeListeners;
        auto rit = std::remove_if(listeners.begin(), listeners.end(), [listener] (const auto& item) {
            return item.listener == listener;
        });
        listeners.erase(rit, listeners.end());
        if(listeners.empty()) {
            registry.erase<Observable<CT>>(object.entity);
        }
    }
}

}
