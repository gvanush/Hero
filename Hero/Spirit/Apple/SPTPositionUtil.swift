//
//  SPTPositionUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation
import simd


extension SPTPosition: SPTObservableComponent {
    
    init(xyz: simd_float3) {
        self.init(variantTag: .XYZ, .init(xyz: xyz))
    }
    
    init(x: Float, y: Float, z: Float) {
        self.init(xyz: .init(x: x, y: y, z: z))
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
    
    static func onDidEmergeSink(object: SPTObject, callback: @escaping DidEmergeCallback) -> SPTAnySubscription {
        
        let subscription = DidEmergeSubscription(observer: callback)
        
        let token = SPTPositionAddDidEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTPositionRemoveDidEmergeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTPositionAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTPositionRemoveWillChangeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTPositionAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTPositionRemoveWillPerishObserver(object, token) }
        
        return subscription
    }
    
}
