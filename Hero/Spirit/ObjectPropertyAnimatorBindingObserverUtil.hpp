//
//  AnimatorBindingObserverUtil.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.08.22.
//

#pragma once

#include "ObjectPropertyAnimatorBinding.hpp"
#include "ComponentObserverUtil.hpp"


namespace spt {

// MARK: WillChangeObservable
template <SPTAnimatableObjectProperty P>
using AnimatorBindingWillChangeObservable = spt::WillChangeObservable<
    spt::AnimatorBinding<P>,
    std::pair<SPTObjectPropertyAnimatorBindingWillChangeObserver, SPTObserverUserInfo>>;

template <SPTAnimatableObjectProperty P>
SPTObserverToken addAnimatorBindingWillChangeObserver(SPTObject object, SPTObjectPropertyAnimatorBindingWillChangeObserver observer, SPTObserverUserInfo userInfo) {
    
    return spt::addComponentObserver<AnimatorBindingWillChangeObservable<P>>([] (auto comp, auto userInfo) {
        userInfo.first(comp.base, userInfo.second);
    }, std::make_pair(observer, userInfo), object);
}

template <SPTAnimatableObjectProperty P>
void removeAnimatorBindingWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentObserver<AnimatorBindingWillChangeObservable<P>>(token, object);
}

template <SPTAnimatableObjectProperty P>
void notifyAnimatorBindingWillChangeObservers(const spt::Registry& registry, SPTEntity entity, const spt::AnimatorBinding<P>& newValue) {
    spt::notifyComponentObservers<AnimatorBindingWillChangeObservable<P>>(registry, entity, newValue);
}

// MARK: AnimatorBindingWillEmergeObservable
template <SPTAnimatableObjectProperty P>
using AnimatorBindingWillEmergeObservable = spt::WillEmergeObservable<
    spt::AnimatorBinding<P>,
    std::pair<SPTObjectPropertyAnimatorBindingWillEmergeObserver, SPTObserverUserInfo>>;

template <SPTAnimatableObjectProperty P>
SPTObserverToken addAnimatorBindingWillEmergeObserver(SPTObject object, SPTObjectPropertyAnimatorBindingWillEmergeObserver observer, SPTObserverUserInfo userInfo) {
    
    return spt::addComponentObserver<AnimatorBindingWillEmergeObservable<P>>([] (auto comp, auto userInfo) {
        userInfo.first(comp.base, userInfo.second);
    }, std::make_pair(observer, userInfo), object);
}

template <SPTAnimatableObjectProperty P>
void removeAnimatorBindingWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentObserver<AnimatorBindingWillEmergeObservable<P>>(token, object);
}

template <SPTAnimatableObjectProperty P>
void notifyAnimatorBindingWillEmergeObservers(const spt::Registry& registry, SPTEntity entity, const spt::AnimatorBinding<P>& newValue) {
    spt::notifyComponentObservers<AnimatorBindingWillEmergeObservable<P>>(registry, entity, newValue);
}

// MARK: WillPerishObservable
template <SPTAnimatableObjectProperty P>
using AnimatorBindingWillPerishObservable = spt::WillPerishObservable<
    spt::AnimatorBinding<P>,
    std::pair<SPTObjectPropertyAnimatorBindingWillPerishObserver, SPTObserverUserInfo>>;

template <SPTAnimatableObjectProperty P>
SPTObserverToken addAnimatorBindingWillPerishObserver(SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTObserverUserInfo userInfo) {
    
    return spt::addComponentObserver<AnimatorBindingWillPerishObservable<P>>([] (auto userInfo) {
        userInfo.first(userInfo.second);
    }, std::make_pair(observer, userInfo), object);
}

template <SPTAnimatableObjectProperty P>
void removeAnimatorBindingWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentObserver<AnimatorBindingWillPerishObservable<P>>(token, object);
}

template <SPTAnimatableObjectProperty P>
void notifyAnimatorBindingWillPerishObservers(const spt::Registry& registry, SPTEntity entity) {
    spt::notifyComponentObservers<AnimatorBindingWillPerishObservable<P>>(registry, entity);
}

}
