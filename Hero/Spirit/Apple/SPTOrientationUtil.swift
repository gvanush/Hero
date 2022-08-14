//
//  SPTOrientationUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


extension SPTOrientation: SPTComponent {
    
    init(euler: SPTEulerOrientation) {
        self.init(variantTag: .euler, .init(euler: euler))
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
        
        let subscription = WillEmergeSubscription(callback: callback) { token in
            SPTOrientationRemoveWillEmergeObserver(object, token)
        }
        
        subscription.token = SPTOrientationAddWillEmergeObserver(object, { newValue, userInfo in
            let cancellable = Unmanaged<WillEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(callback: callback) { token in
            SPTOrientationRemoveWillChangeObserver(object, token)
        }
        
        subscription.token = SPTOrientationAddWillChangeObserver(object, { newValue, userInfo in
            let cancellable = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(callback: callback) { token in
            SPTOrientationRemoveWillPerishObserver(object, token)
        }
        
        subscription.token = SPTOrientationAddWillPerishObserver(object, { userInfo in
            let cancellable = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
}
