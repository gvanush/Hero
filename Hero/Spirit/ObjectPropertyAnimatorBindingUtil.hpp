//
//  AnimatorBindingUtil.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.08.22.
//

#pragma once

#include "ObjectPropertyAnimatorBinding.hpp"
#include "ObjectPropertyAnimatorBindingObserverUtil.hpp"
#include "Scene.hpp"

namespace spt {

template <SPTAnimatableObjectProperty P>
void bindAnimator(SPTObject object, const SPTAnimatorBinding& animatorBinding) {
    auto& registry = Scene::getRegistry(object);
    
    AnimatorBinding<P> comp {animatorBinding};
    notifyAnimatorBindingWillEmergeObservers<P>(registry, object.entity, comp);
    
    registry.emplace<AnimatorBinding<P>>(object.entity, comp);
}

template <SPTAnimatableObjectProperty P>
void updateAnimatorBinding(SPTObject object, const SPTAnimatorBinding& animatorBinding) {
    auto& registry = Scene::getRegistry(object);
    
    AnimatorBinding<P> comp {animatorBinding};
    notifyAnimatorBindingWillChangeObservers<P>(registry, object.entity, comp);
    
    registry.get<AnimatorBinding<P>>(object.entity) = comp;
}

template <SPTAnimatableObjectProperty P>
void unbindAnimator(SPTObject object) {
    auto& registry = Scene::getRegistry(object);
    notifyAnimatorBindingWillPerishObservers<P>(registry, object.entity);
    registry.erase<AnimatorBinding<P>>(object.entity);
}

template <SPTAnimatableObjectProperty P>
SPTAnimatorBinding getAnimatorBinding(SPTObject object) {
    return Scene::getRegistry(object).get<AnimatorBinding<P>>(object.entity).base;
}

template <SPTAnimatableObjectProperty P>
SPTAnimatorBinding* tryGetAnimatorBinding(SPTObject object) {
    if(const auto binding = Scene::getRegistry(object).try_get<AnimatorBinding<P>>(object.entity)) {
        return &binding->base;
    }
    return nullptr;
}

template <SPTAnimatableObjectProperty P>
bool isAnimatorBound(SPTObject object) {
    auto& registry = Scene::getRegistry(object);
    return registry.all_of<AnimatorBinding<P>>(object.entity);
}

}
