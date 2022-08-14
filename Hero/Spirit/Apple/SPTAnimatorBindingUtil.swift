//
//  SPTAnimatorBindingUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.08.22.
//

import Foundation


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
