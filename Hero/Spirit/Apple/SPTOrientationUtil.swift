//
//  SPTOrientationUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


extension SPTOrientation: SPTObservableComponent {
    
    init(euler: SPTEulerOrientation) {
        self.init(type: .euler, .init(euler: euler))
    }
    
    init(lookAt: SPTLookAtOrientation) {
        self.init(type: .lookAt, .init(lookAt: lookAt))
    }
    
    public static func == (lhs: SPTOrientation, rhs: SPTOrientation) -> Bool {
        SPTOrientationEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTOrientation, object: SPTObject) {
        SPTOrientationMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTOrientation, object: SPTObject) {
        if SPTOrientationExists(object) {
            SPTOrientationUpdate(object, component)
        } else {
            SPTOrientationMake(object, component)
        }
    }
    
    static func update(_ component: SPTOrientation, object: SPTObject) {
        SPTOrientationUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTOrientationDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTOrientation {
        SPTOrientationGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTOrientation? {
        SPTOrientationTryGet(object)?.pointee
    }
    
    static func onWillEmergeSink(object: SPTObject, callback: @escaping WillEmergeCallback) -> SPTAnySubscription {
        
        let subscription = WillEmergeSubscription(observer: callback)
        
        let token = SPTOrientationAddWillEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveWillEmergeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTOrientationAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveWillChangeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTOrientationAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveWillPerishObserver(object, token) }
        
        return subscription
    }
    
}
