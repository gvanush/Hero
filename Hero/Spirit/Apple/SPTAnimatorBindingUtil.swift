//
//  SPTAnimatorBindingUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.08.22.
//

import Foundation


extension SPTObjectProperty {
    
    typealias AnimatorBindingWillEmergeCallback = ObjectWillEmergeCallback<SPTAnimatorBinding>
    typealias AnimatorBindingWillEmergeSubscription = SPTSubscription<AnimatorBindingWillEmergeCallback>
    
    typealias AnimatorBindingWillChangeCallback = ObjectWillChangeCallback<SPTAnimatorBinding>
    typealias AnimatorBindingWillChangeSubscription = SPTSubscription<AnimatorBindingWillChangeCallback>
    
    typealias AnimatorBindingWillPerishCallback = ObjectWillPerishCallback
    typealias AnimatorBindingWillPerishSubscription = SPTSubscription<AnimatorBindingWillPerishCallback>
    
    func bindAnimator(object: SPTObject, binding: SPTAnimatorBinding) {
        SPTObjectPropertyBindAnimator(self, object, binding)
    }
    
    func updateAnimatorBinding(object: SPTObject, binding: SPTAnimatorBinding) {
        SPTObjectPropertyUpdateAnimatorBinding(self, object, binding)
    }
    
    func unbindAnimator(object: SPTObject) {
        SPTObjectPropertyUnbindAnimator(self, object)
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
    
    func onAnimatorBindingWillEmergeSink(object: SPTObject, callback: @escaping AnimatorBindingWillEmergeCallback) -> SPTAnySubscription {
        
        let subscription = AnimatorBindingWillEmergeSubscription(observer: callback)
        
        let token = SPTObjectPropertyAddAnimatorBindingWillEmergeObserver(self, object, { newValue, userInfo in
            let subscription = Unmanaged<AnimatorBindingWillEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTObjectPropertyRemoveAnimatorBindingWillEmergeObserver(self, object, token) }
        
        return subscription
    }
    
    func onAnimatorBindingWillChangeSink(object: SPTObject, callback: @escaping AnimatorBindingWillEmergeCallback) -> SPTAnySubscription {
        
        let subscription = AnimatorBindingWillChangeSubscription(observer: callback)
        
        let token = SPTObjectPropertyAddAnimatorBindingWillChangeObserver(self, object, { newValue, userInfo in
            let subscription = Unmanaged<AnimatorBindingWillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTObjectPropertyRemoveAnimatorBindingWillChangeObserver(self, object, token) }
        
        return subscription
    }
    
    func onAnimatorBindingWillPerishSink(object: SPTObject, callback: @escaping AnimatorBindingWillPerishCallback) -> SPTAnySubscription {
        
        let subscription = AnimatorBindingWillPerishSubscription(observer: callback)
        
        let token = SPTObjectPropertyAddAnimatorBindingWillPerishObserver(self, object, { userInfo in
            let subscription = Unmanaged<AnimatorBindingWillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTObjectPropertyRemoveAnimatorBindingWillPerishObserver(self, object, token) }
        
        return subscription
    }
    
}

extension SPTAnimatorBinding: SPTComponent {
    
    public static func == (lhs: SPTAnimatorBinding, rhs: SPTAnimatorBinding) -> Bool {
        SPTAnimatorBindingEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTAnimatorBinding, object: SPTObject) {
        SPTAnimatorBindingMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTAnimatorBinding, object: SPTObject) {
        if SPTAnimatorBindingExists(object) {
            SPTAnimatorBindingUpdate(object, component)
        } else {
            SPTAnimatorBindingMake(object, component)
        }
    }
    
    static func update(_ component: SPTAnimatorBinding, object: SPTObject) {
        SPTAnimatorBindingUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTAnimatorBindingDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTAnimatorBinding {
        SPTAnimatorBindingGet(object)
    }
    
    static func tryGet(object: SPTObject) -> Self? {
        SPTAnimatorBindingTryGet(object)?.pointee
    }
    
    static func onWillEmergeSink(object: SPTObject, callback: @escaping WillEmergeCallback) -> SPTAnySubscription {
        
        let subscription = WillEmergeSubscription(observer: callback)
        
        let token = SPTAnimatorBindingAddWillEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTAnimatorBindingRemoveWillEmergeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTAnimatorBindingAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTAnimatorBindingRemoveWillChangeObserver(object, token) }
        
        return subscription
    }
    
    
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTAnimatorBindingAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTAnimatorBindingRemoveWillPerishObserver(object, token) }
        
        return subscription
    }
    
}
