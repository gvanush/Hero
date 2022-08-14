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

#include <array>

namespace spt {

constexpr size_t kMaxObserverCount = 8;

template <typename O>
inline SPTComponentObserverToken addComponentObserver(SPTObject object, typename O::Observer observer, SPTComponentObserverUserInfo userInfo) {
    assert(observer);
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    if(auto observable = registry.try_get<O>(object.entity)) {
        auto it = std::find_if(observable->observerItems.begin(), observable->observerItems.end(), [](const auto& item) {
            return item.observer == nullptr;
        });
        assert(it != observable->observerItems.end());
        it->observer = observer;
        it->userInfo = userInfo;
        return static_cast<SPTComponentObserverToken>(it - observable->observerItems.begin());
    } else {
        registry.emplace<O>(object.entity, O { { {observer, userInfo} } });
        return SPTComponentObserverToken{0};
    }
}

 
template <typename O>
inline void removeComponentObserver(SPTObject object, SPTComponentObserverToken token) {
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    if(auto observable = registry.try_get<O>(object.entity)) {
        observable->observerItems[token].observer = nullptr;
        observable->observerItems[token].userInfo = nullptr;
        // NOTE: Not removing the observable component itself in case there are no observers
        // with the assumption that they will come up again
    }
}

template <typename O, typename... Args>
inline void notifyComponentObservers(const spt::Registry& registry, SPTEntity entity, Args... args) {
    if(auto observable = registry.try_get<O>(entity)) {
        for(const auto& item: observable->observerItems) {
            if(item.observer) {
                item.observer(args..., item.userInfo);
            }
        }
    }
}


// MARK: WillChangeObservable
template <typename C>
struct WillChangeObservable {
    using Observer = ComponentWillChangeObserver<C>;
    std::array<ComponentObserverItem<Observer>, kMaxObserverCount> observerItems {};
};


template <typename C>
inline SPTComponentObserverToken addComponentWillChangeObserver(SPTObject object, typename WillChangeObservable<C>::Observer observer, SPTComponentObserverUserInfo userInfo) {
    return addComponentObserver<WillChangeObservable<C>>(object, observer, userInfo);
}


template <typename C>
inline void removeComponentWillChangeObserver(SPTObject object, SPTComponentObserverToken token) {
    removeComponentObserver<WillChangeObservable<C>>(object, token);
}

template <typename C>
inline void notifyWillChangeComponentObservers(const spt::Registry& registry, SPTEntity entity, const C& newValue) {
    notifyComponentObservers<WillChangeObservable<C>>(registry, entity, newValue);
}

// MARK: WillEmergeObservable
template <typename C>
struct WillEmergeObservable {
    using Observer = ComponentWillEmergeObserver<C>;
    std::array<ComponentObserverItem<Observer>, kMaxObserverCount> observerItems {};
};


template <typename C>
inline SPTComponentObserverToken addComponentWillEmergeObserver(SPTObject object, typename WillEmergeObservable<C>::Observer observer, SPTComponentObserverUserInfo userInfo) {
    return addComponentObserver<WillEmergeObservable<C>>(object, observer, userInfo);
}


template <typename C>
inline void removeComponentWillEmergeObserver(SPTObject object, SPTComponentObserverToken token) {
    removeComponentObserver<WillEmergeObservable<C>>(object, token);
}


template <typename C>
inline void notifyWillEmergeComponentObservers(const spt::Registry& registry, SPTEntity entity, const C& newValue) {
    notifyComponentObservers<WillEmergeObservable<C>>(registry, entity, newValue);
}


// MARK: WillPerishObservable
template <typename C>
struct WillPerishObservable {
    using Observer = ComponentWillPerishObserver<C>;
    std::array<ComponentObserverItem<Observer>, kMaxObserverCount> observerItems {};
};


template <typename C>
inline SPTComponentObserverToken addComponentWillPerishObserver(SPTObject object, typename WillPerishObservable<C>::Observer observer, SPTComponentObserverUserInfo userInfo) {
    return addComponentObserver<WillPerishObservable<C>>(object, observer, userInfo);
}


template <typename C>
inline void removeComponentWillPerishObserver(SPTObject object, SPTComponentObserverToken token) {
    removeComponentObserver<WillPerishObservable<C>>(object, token);
}


template <typename C>
inline void notifyWillPerishComponentObservers(const spt::Registry& registry, SPTEntity entity) {
    notifyComponentObservers<WillPerishObservable<C>>(registry, entity);
}


// TODO: Remove
template <typename CT>
struct Observable {
    std::vector<WillChangeListenerItem<CT>> willChangeListeners;
};


template <typename CT>
inline void addComponentWillChangeListener(SPTObject object, SPTListener listener, WillChangeCallback<CT> callback) {
    assert(listener && callback);
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    if(auto observable = registry.try_get<Observable<CT>>(object.entity)) {
        observable->willChangeListeners.emplace_back(WillChangeListenerItem<CT> {listener, callback});
    } else {
        registry.emplace<Observable<CT>>(object.entity, Observable<CT>{ { {listener, callback} } });
    }
}


template <typename CT>
inline void removeComponentWillChangeListenerCallback(SPTObject object, SPTListener listener, WillChangeCallback<CT> callback) {
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
inline void removeComponentWillChangeListener(SPTObject object, SPTListener listener) {
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
