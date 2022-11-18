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
#include "AnimatorManager.hpp"

namespace spt {

template <SPTAnimatableObjectProperty P>
void bindAnimator(SPTObject object, const SPTAnimatorBinding& animatorBinding) {
    auto& registry = Scene::getRegistry(object);
    
    AnimatorBinding<P> comp {animatorBinding};
    
    registry.emplace<AnimatorBinding<P>>(object.entity, comp);
    
    spt::AnimatorManager::active().onObjectPropertyBind(animatorBinding.animatorId, object, P);
    
    notifyAnimatorBindingDidEmergeObservers<P>(registry, object.entity, comp);
}

template <SPTAnimatableObjectProperty P>
void updateAnimatorBinding(SPTObject object, const SPTAnimatorBinding& animatorBinding) {
    auto& registry = Scene::getRegistry(object);
    
    AnimatorBinding<P> newBinding {animatorBinding};
    notifyAnimatorBindingWillChangeObservers<P>(registry, object.entity, newBinding);
    
    auto& binding = registry.get<AnimatorBinding<P>>(object.entity);
    const auto animatorChanged = (binding.base.animatorId != animatorBinding.animatorId);
    
    if(animatorChanged) {
        spt::AnimatorManager::active().onObjectPropertyUnbind(binding.base.animatorId, object, P);
    }
    
    binding = newBinding;
    
    if(animatorChanged) {
        spt::AnimatorManager::active().onObjectPropertyBind(animatorBinding.animatorId, object, P);
    }
}

template <SPTAnimatableObjectProperty P>
void unbindAnimator(SPTObject object) {
    auto& registry = Scene::getRegistry(object);
    notifyAnimatorBindingWillPerishObservers<P>(registry, object.entity);
    
    const auto& animatorBinding = registry.get<AnimatorBinding<P>>(object.entity);
    spt::AnimatorManager::active().onObjectPropertyUnbind(animatorBinding.base.animatorId, object, P);
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
