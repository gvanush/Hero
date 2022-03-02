//
//  ComponentUpdateNotifier.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 23.12.21.
//

#pragma once

#include "Base.hpp"

namespace spt {

template <typename CT>
class ComponentUpdateNotifier {
public:
    ComponentUpdateNotifier(Registry& registry)
    : _observer{registry, entt::collector.update<CT>().template where<Observable<CT>>()}
    , _registry{registry} {
    }
    
    void notify() {
        _observer.each([this] (const auto entity) {
            const auto& observable = _registry.get<Observable<CT>>(entity);
            for(const auto& item: observable.listeners) {
                item.callback(item.listener);
            }
        });
    }
    
    static void onWillChange(Registry& registry, SPTEntity entity, const CT& newValue) {
        if(auto observable = registry.try_get<Observable<CT>>(entity)) {
            for(const auto& item: observable->willChangeListeners) {
                item.callback(item.listener, newValue);
            }
        }
    }
    
private:
    EntityObserver _observer;
    const Registry& _registry;
};

}
