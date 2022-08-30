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

constexpr size_t kMaxObserverCount = 8;

template <typename O, typename U>
struct ComponentObserverItem {
    O observer;
    U userInfo;
};


template <typename O, typename U>
SPTObserverToken addComponentObserver(SPTObject object, typename O::Observer observer, U userInfo) {
    assert(observer);
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    if(auto observable = registry.try_get<O>(object.entity)) {
        auto it = std::find_if(observable->observerItems.begin(), observable->observerItems.end(), [](const auto& item) {
            return item.observer == nullptr;
        });
        assert(it != observable->observerItems.end());
        it->observer = observer;
        it->userInfo = userInfo;
        return static_cast<SPTObserverToken>(it - observable->observerItems.begin());
    } else {
        registry.emplace<O>(object.entity, O { { {observer, userInfo} } });
        return SPTObserverToken{0};
    }
}


template <typename O>
void removeComponentObserver(SPTObject object, SPTObserverToken token) {
    auto& registry = static_cast<Scene*>(object.sceneHandle)->registry;
    // Object may have been destroyed before its observers trying
    // to unsubscribe, hence simply ignoring the request
    if(!registry.valid(object.entity)) {
        return;
    }
    if(auto observable = registry.try_get<O>(object.entity)) {
        observable->observerItems[token].observer = nullptr;
        // Not removing the observable component itself in case there are
        // no observers with the assumption that they will come up again
    }
}

template <typename O, typename... Args>
void notifyComponentObservers(const spt::Registry& registry, SPTEntity entity, Args... args) {
    if(auto observable = registry.try_get<O>(entity)) {
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

template <typename C>
SPTObserverToken addComponentWillChangeObserver(SPTObject object, typename WillChangeObservable<C, SPTComponentObserverUserInfo>::Observer observer, SPTComponentObserverUserInfo userInfo) {
    return addComponentObserver<WillChangeObservable<C, SPTComponentObserverUserInfo>>(object, observer, userInfo);
}

template <typename C>
void removeComponentWillChangeObserver(SPTObject object, SPTObserverToken token) {
    removeComponentObserver<WillChangeObservable<C, SPTComponentObserverUserInfo>>(object, token);
}

template <typename C>
void notifyComponentWillChangeObservers(const spt::Registry& registry, SPTEntity entity, const C& newValue) {
    notifyComponentObservers<WillChangeObservable<C, SPTComponentObserverUserInfo>>(registry, entity, newValue);
}


// MARK: WillEmergeObservable
template <typename C, typename U>
struct WillEmergeObservable {
    using Observer = void (*)(C, U);
    std::array<ComponentObserverItem<Observer, U>, kMaxObserverCount> observerItems {};
};

template <typename C>
SPTObserverToken addComponentWillEmergeObserver(SPTObject object, typename WillEmergeObservable<C, SPTComponentObserverUserInfo>::Observer observer, SPTComponentObserverUserInfo userInfo) {
    return addComponentObserver<WillEmergeObservable<C, SPTComponentObserverUserInfo>>(object, observer, userInfo);
}

template <typename C>
void removeComponentWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    removeComponentObserver<WillEmergeObservable<C, SPTComponentObserverUserInfo>>(object, token);
}

template <typename C>
void notifyComponentWillEmergeObservers(const spt::Registry& registry, SPTEntity entity, const C& newValue) {
    notifyComponentObservers<WillEmergeObservable<C, SPTComponentObserverUserInfo>>(registry, entity, newValue);
}


// MARK: WillPerishObservable
template <typename C, typename U>
struct WillPerishObservable {
    using Observer = void (*)(U);
    std::array<ComponentObserverItem<Observer, U>, kMaxObserverCount> observerItems {};
};


template <typename C>
SPTObserverToken addComponentWillPerishObserver(SPTObject object, typename WillPerishObservable<C, SPTComponentObserverUserInfo>::Observer observer, SPTComponentObserverUserInfo userInfo) {
    return addComponentObserver<WillPerishObservable<C, SPTComponentObserverUserInfo>>(object, observer, userInfo);
}


template <typename C>
void removeComponentWillPerishObserver(SPTObject object, SPTObserverToken token) {
    removeComponentObserver<WillPerishObservable<C, SPTComponentObserverUserInfo>>(object, token);
}


template <typename C>
void notifyComponentWillPerishObservers(const spt::Registry& registry, SPTEntity entity) {
    notifyComponentObservers<WillPerishObservable<C, SPTComponentObserverUserInfo>>(registry, entity);
}

}
