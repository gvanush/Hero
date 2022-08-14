//
//  SPTScaleUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


extension SPTScale: SPTComponent {
    
    public static func == (lhs: SPTScale, rhs: SPTScale) -> Bool {
        SPTScaleEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTScale, object: SPTObject) {
        SPTScaleMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTScale, object: SPTObject) {
        if SPTScaleExists(object) {
            SPTScaleUpdate(object, component)
        } else {
            SPTScaleMake(object, component)
        }
    }
    
    static func update(_ component: SPTScale, object: SPTObject) {
        SPTScaleUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTScaleDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTScale {
        SPTScaleGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTScale? {
        SPTScaleTryGet(object)?.pointee
    }
    
    static func onWillEmergeSink(object: SPTObject, callback: @escaping WillEmergeCallback) -> SPTAnySubscription {
        
        let subscription = WillEmergeSubscription(observer: callback)
        
        let token = SPTScaleAddWillEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())

        subscription.canceller = { SPTScaleRemoveWillEmergeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTScaleAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTScaleRemoveWillChangeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTScaleAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTScaleRemoveWillPerishObserver(object, token) }
        
        return subscription
    }
    
}
