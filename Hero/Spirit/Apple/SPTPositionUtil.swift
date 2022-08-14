//
//  SPTPositionUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation
import simd


extension SPTPosition: SPTComponent {
    
    init(xyz: simd_float3) {
        self.init(variantTag: .XYZ, .init(xyz: xyz))
    }
    
    public static func == (lhs: SPTPosition, rhs: SPTPosition) -> Bool {
        SPTPositionEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTPosition, object: SPTObject) {
        SPTPositionMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTPosition, object: SPTObject) {
        if SPTPositionExists(object) {
            SPTPositionUpdate(object, component)
        } else {
            SPTPositionMake(object, component)
        }
    }
    
    static func update(_ component: SPTPosition, object: SPTObject) {
        SPTPositionUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTPositionDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTPosition {
        SPTPositionGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTPosition? {
        SPTPositionTryGet(object)?.pointee
    }
    
    static func onWillEmergeSink(object: SPTObject, callback: @escaping WillEmergeCallback) -> SPTAnySubscription {
        
        let subscription = WillEmergeSubscription(callback: callback) { token in
            SPTPositionRemoveWillEmergeObserver(object, token)
        }
        
        subscription.token = SPTPositionAddWillEmergeObserver(object, { newValue, userInfo in
            let cancellable = Unmanaged<WillEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(callback: callback) { token in
            SPTPositionRemoveWillChangeObserver(object, token)
        }
        
        subscription.token = SPTPositionAddWillChangeObserver(object, { newValue, userInfo in
            let cancellable = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(callback: callback) { token in
            SPTPositionRemoveWillPerishObserver(object, token)
        }
        
        subscription.token = SPTPositionAddWillPerishObserver(object, { userInfo in
            let cancellable = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            cancellable.callback()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        return subscription
    }
    
}
