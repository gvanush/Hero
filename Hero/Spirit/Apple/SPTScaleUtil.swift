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
        
        let subscription = WillEmergeSubscription(callback: callback) { token in
            SPTScaleRemoveWillEmergeObserver(object, token)
        }
        
        subscription.token = SPTScaleAddWillEmergeObserver(object, { newValue, userInfo in
            let cancellable = Unmanaged<WillEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(callback: callback) { token in
            SPTScaleRemoveWillChangeObserver(object, token)
        }
        
        subscription.token = SPTScaleAddWillChangeObserver(object, { newValue, userInfo in
            let cancellable = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(callback: callback) { token in
            SPTScaleRemoveWillPerishObserver(object, token)
        }
        
        subscription.token = SPTScaleAddWillPerishObserver(object, { userInfo in
            let cancellable = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
}
