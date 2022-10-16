//
//  ComponentObserverUtil.hpp
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

template <typename O, typename U>
struct ComponentObserverItem {
    O observer;
    U userInfo;
};

// MARK: Utils
template <typename O, typename U, typename R, typename E>
SPTObserverToken addComponentObserver(typename O::Observer observer, U userInfo, R& registry, E entity) {
    assert(observer);
    if(auto observable = registry.template try_get<O>(entity)) {
        auto it = std::find_if(observable->observerItems.begin(), observable->observerItems.end(), [](const auto& item) {
            return item.observer == nullptr;
        });
        assert(it != observable->observerItems.end()); // No free slot to register observer
        it->observer = observer;
        it->userInfo = userInfo;
        return static_cast<SPTObserverToken>(it - observable->observerItems.begin());
    } else {
        registry.template emplace<O>(entity, O { { {observer, userInfo} } });
        return SPTObserverToken{0};
    }
}

template <typename O, typename U>
SPTObserverToken addComponentObserver(typename O::Observer observer, U userInfo, SPTObject object) {
    return addComponentObserver<O>(observer, userInfo, Scene::getRegistry(object), object.entity);
}


template <typename O, typename R, typename E>
void removeComponentObserver(SPTObserverToken token, R& registry, E entity) {
    // Object may have been destroyed before its observers trying
    // to unsubscribe, hence simply ignoring the request
    if(!registry.valid(entity)) {
        return;
    }
    if(auto observable = registry.template try_get<O>(entity)) {
        observable->observerItems[token].observer = nullptr;
        // Not removing the observable component itself in case there are
        // no observers with the assumption that they will come up again
    }
}

template <typename O>
void removeComponentObserver(SPTObserverToken token, SPTObject object) {
    removeComponentObserver<O>(token, Scene::getRegistry(object), object.entity);
}


template <typename O, typename R, typename E, typename... Args>
void notifyComponentObservers(const R& registry, E entity, Args... args) {
    if(auto observable = registry.template try_get<O>(entity)) {
        for(const auto& item: observable->observerItems) {
            if(item.observer) {
                item.observer(args..., item.userInfo);
            }
        }
    }
}


// MARK: WillChangeObservable
template <typename C, typename U>
struct WillChangeObservable {
    using Observer = void (*)(C, U);
    std::array<ComponentObserverItem<Observer, U>, kMaxObserverCount> observerItems {};
};

template <typename C, typename R, typename E>
SPTObserverToken addComponentWillChangeObserver(typename WillChangeObservable<C, SPTObserverUserInfo>::Observer observer, SPTObserverUserInfo userInfo, R& registry, E entity) {
    return addComponentObserver<WillChangeObservable<C, SPTObserverUserInfo>>(observer, userInfo, registry, entity);
}

template <typename C>
SPTObserverToken addComponentWillChangeObserver(SPTObject object, typename WillChangeObservable<C, SPTObserverUserInfo>::Observer observer, SPTObserverUserInfo userInfo) {
    return addComponentObserver<WillChangeObservable<C, SPTObserverUserInfo>>(observer, userInfo, object);
}

template <typename C, typename R, typename E>
void removeComponentWillChangeObserver(SPTObserverToken token, R& registry, E entity) {
    removeComponentObserver<WillChangeObservable<C, SPTObserverUserInfo>>(token, registry, entity);
}

template <typename C>
void removeComponentWillChangeObserver(SPTObject object, SPTObserverToken token) {
    removeComponentObserver<WillChangeObservable<C, SPTObserverUserInfo>>(token, object);
}

template <typename C, typename R, typename E>
void notifyComponentWillChangeObservers(const R& registry, E entity, const C& newValue) {
    notifyComponentObservers<WillChangeObservable<C, SPTObserverUserInfo>>(registry, entity, newValue);
}


// MARK: WillEmergeObservable
template <typename C, typename U>
struct WillEmergeObservable {
    using Observer = void (*)(C, U);
    std::array<ComponentObserverItem<Observer, U>, kMaxObserverCount> observerItems {};
};

template <typename C>
SPTObserverToken addComponentWillEmergeObserver(SPTObject object, typename WillEmergeObservable<C, SPTObserverUserInfo>::Observer observer, SPTObserverUserInfo userInfo) {
    return addComponentObserver<WillEmergeObservable<C, SPTObserverUserInfo>>(observer, userInfo, object);
}

template <typename C>
void removeComponentWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    removeComponentObserver<WillEmergeObservable<C, SPTObserverUserInfo>>(token, object);
}

template <typename C>
void notifyComponentWillEmergeObservers(const spt::Registry& registry, SPTEntity entity, const C& newValue) {
    notifyComponentObservers<WillEmergeObservable<C, SPTObserverUserInfo>>(registry, entity, newValue);
}


// MARK: WillPerishObservable
template <typename C, typename U>
struct WillPerishObservable {
    using Observer = void (*)(U);
    std::array<ComponentObserverItem<Observer, U>, kMaxObserverCount> observerItems {};
};


template <typename C>
SPTObserverToken addComponentWillPerishObserver(SPTObject object, typename WillPerishObservable<C, SPTObserverUserInfo>::Observer observer, SPTObserverUserInfo userInfo) {
    return addComponentObserver<WillPerishObservable<C, SPTObserverUserInfo>>(observer, userInfo, object);
}


template <typename C>
void removeComponentWillPerishObserver(SPTObject object, SPTObserverToken token) {
    removeComponentObserver<WillPerishObservable<C, SPTObserverUserInfo>>(token, object);
}


template <typename C>
void notifyComponentWillPerishObservers(const spt::Registry& registry, SPTEntity entity) {
    notifyComponentObservers<WillPerishObservable<C, SPTObserverUserInfo>>(registry, entity);
}

}
