//
//  SPTAnimatableObjectPropertyUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 16.08.22.
//

import Foundation


extension SPTAnimatableObjectProperty: SPTAnimatableProperty, CaseIterable {
    
    public static var allCases: [SPTAnimatableObjectProperty] = [
        .cartesianPositionX,
        .cartesianPositionY,
        .cartesianPositionZ,
        .linearPositionOffset,
        .sphericalPositionRadius,
        .sphericalPositionLongitude,
        .sphericalPositionLatitude,
        .cylindricalPositionRadius,
        .cylindricalPositionLongitude,
        .cylindricalPositionHeight,
        .hue,
        .saturation,
        .brightness,
        .red,
        .green,
        .blue,
        .shininess
    ]
    
    public var id: Self {
        self
    }
    
    func bind(_ binding: SPTAnimatorBinding, object: SPTObject) {
        SPTObjectPropertyBindAnimator(self, object, binding)
    }
    
    func bindOrUpdate(_ binding: SPTAnimatorBinding, object: SPTObject) {
        if SPTObjectPropertyIsAnimatorBound(self, object) {
            SPTObjectPropertyUpdateAnimatorBinding(self, object, binding)
        } else {
            SPTObjectPropertyBindAnimator(self, object, binding)
        }
    }
    
    func updateAnimatorBinding(_ binding: SPTAnimatorBinding, object: SPTObject) {
        SPTObjectPropertyUpdateAnimatorBinding(self, object, binding)
    }
    
    func unbindAnimator(object: SPTObject) {
        SPTObjectPropertyUnbindAnimator(self, object)
    }
    
    func unbindAnimatorIfBound(object: SPTObject) {
        SPTObjectPropertyUnbindAnimatorIfBound(self, object)
    }
    
    func getAnimatorBinding(object: SPTObject) -> SPTAnimatorBinding {
        SPTObjectPropertyGetAnimatorBinding(self, object)
    }
    
    func tryGetAnimatorBinding(object: SPTObject) -> SPTAnimatorBinding? {
        SPTObjectPropertyTryGetAnimatorBinding(self, object)?.pointee
    }
    
    func isAnimatorBound(object: SPTObject) -> Bool {
        SPTObjectPropertyIsAnimatorBound(self, object)
    }
    
    func onAnimatorBindingDidEmergeSink(object: SPTObject, callback: @escaping AnimatorBindingDidEmergeCallback) -> SPTAnySubscription {
        
        let subscription = AnimatorBindingDidEmergeSubscription(observer: callback)
        
        let token = SPTObjectPropertyAddAnimatorBindingDidEmergeObserver(self, object, { newValue, userInfo in
            let subscription = Unmanaged<AnimatorBindingDidEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTObjectPropertyRemoveAnimatorBindingDidEmergeObserver(self, object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    func onAnimatorBindingWillChangeSink(object: SPTObject, callback: @escaping AnimatorBindingWillChangeCallback) -> SPTAnySubscription {
        
        let subscription = AnimatorBindingWillChangeSubscription(observer: callback)
        
        let token = SPTObjectPropertyAddAnimatorBindingWillChangeObserver(self, object, { newValue, userInfo in
            let subscription = Unmanaged<AnimatorBindingWillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = {
            SPTObjectPropertyRemoveAnimatorBindingWillChangeObserver(self, object, token)
        }
        
        return subscription.eraseToAnySubscription()
    }
    
    func onAnimatorBindingDidChangeSink(object: SPTObject, callback: @escaping AnimatorBindingDidChangeCallback) -> SPTAnySubscription {
        
        let subscription = AnimatorBindingDidChangeSubscription(observer: callback)
        
        let token = SPTObjectPropertyAddAnimatorBindingDidChangeObserver(self, object, { newValue, userInfo in
            let subscription = Unmanaged<AnimatorBindingDidChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = {
            SPTObjectPropertyRemoveAnimatorBindingDidChangeObserver(self, object, token)
        }
        
        return subscription.eraseToAnySubscription()
    }
    
    func onAnimatorBindingWillPerishSink(object: SPTObject, callback: @escaping AnimatorBindingWillPerishCallback) -> SPTAnySubscription {
        
        let subscription = AnimatorBindingWillPerishSubscription(observer: callback)
        
        let token = SPTObjectPropertyAddAnimatorBindingWillPerishObserver(self, object, { userInfo in
            let subscription = Unmanaged<AnimatorBindingWillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTObjectPropertyRemoveAnimatorBindingWillPerishObserver(self, object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
}
