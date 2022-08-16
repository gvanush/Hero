//
//  AnimatorBindingObserverUtil.hpp
//  Hero
//
//  Created by Vanush Grigoryan on 15.08.22.
//

#pragma once

#include "ObjectProperty.hpp"
#include "ComponentObserverUtil.hpp"


namespace spt {

// MARK: WillChangeObservable
template <SPTObjectProperty P>
using AnimatorBindingWillChangeObservable = spt::WillChangeObservable<
    spt::AnimatorBinding<P>,
    std::pair<SPTObjectPropertyAnimatorBindingWillChangeObserver, SPTComponentObserverUserInfo>>;

template <SPTObjectProperty P>
SPTObserverToken addAnimatorBindingWillChangeObserver(SPTObject object, SPTObjectPropertyAnimatorBindingWillChangeObserver observer, SPTComponentObserverUserInfo userInfo) {
    
    return spt::addComponentObserver<AnimatorBindingWillChangeObservable<P>>(object, [] (auto comp, auto userInfo) {
        userInfo.first(comp.base, userInfo.second);
    }, std::make_pair(observer, userInfo));
}

template <SPTObjectProperty P>
void removeAnimatorBindingWillChangeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentObserver<AnimatorBindingWillChangeObservable<P>>(object, token);
}

template <SPTObjectProperty P>
void notifyAnimatorBindingWillChangeObservers(const spt::Registry& registry, SPTEntity entity, const spt::AnimatorBinding<P>& newValue) {
    spt::notifyComponentObservers<AnimatorBindingWillChangeObservable<P>>(registry, entity, newValue);
}

// MARK: AnimatorBindingWillEmergeObservable
template <SPTObjectProperty P>
using AnimatorBindingWillEmergeObservable = spt::WillEmergeObservable<
    spt::AnimatorBinding<P>,
    std::pair<SPTObjectPropertyAnimatorBindingWillEmergeObserver, SPTComponentObserverUserInfo>>;

template <SPTObjectProperty P>
SPTObserverToken addAnimatorBindingWillEmergeObserver(SPTObject object, SPTObjectPropertyAnimatorBindingWillEmergeObserver observer, SPTComponentObserverUserInfo userInfo) {
    
    return spt::addComponentObserver<AnimatorBindingWillEmergeObservable<P>>(object, [] (auto comp, auto userInfo) {
        userInfo.first(comp.base, userInfo.second);
    }, std::make_pair(observer, userInfo));
}

template <SPTObjectProperty P>
void removeAnimatorBindingWillEmergeObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentObserver<AnimatorBindingWillEmergeObservable<P>>(object, token);
}

template <SPTObjectProperty P>
void notifyAnimatorBindingWillEmergeObservers(const spt::Registry& registry, SPTEntity entity, const spt::AnimatorBinding<P>& newValue) {
    spt::notifyComponentObservers<AnimatorBindingWillEmergeObservable<P>>(registry, entity, newValue);
}

// MARK: WillPerishObservable
template <SPTObjectProperty P>
using AnimatorBindingWillPerishObservable = spt::WillPerishObservable<
    spt::AnimatorBinding<P>,
    std::pair<SPTObjectPropertyAnimatorBindingWillPerishObserver, SPTComponentObserverUserInfo>>;

template <SPTObjectProperty P>
SPTObserverToken addAnimatorBindingWillPerishObserver(SPTObject object, SPTObjectPropertyAnimatorBindingWillPerishObserver observer, SPTComponentObserverUserInfo userInfo) {
    
    return spt::addComponentObserver<AnimatorBindingWillPerishObservable<P>>(object, [] (auto userInfo) {
        userInfo.first(userInfo.second);
    }, std::make_pair(observer, userInfo));
}

template <SPTObjectProperty P>
void removeAnimatorBindingWillPerishObserver(SPTObject object, SPTObserverToken token) {
    spt::removeComponentObserver<AnimatorBindingWillPerishObservable<P>>(object, token);
}

template <SPTObjectProperty P>
void notifyAnimatorBindingWillPerishObservers(const spt::Registry& registry, SPTEntity entity) {
    spt::notifyComponentObservers<AnimatorBindingWillPerishObservable<P>>(registry, entity);
}

}
