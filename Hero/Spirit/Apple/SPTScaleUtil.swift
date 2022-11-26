//
//  SPTScaleUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


extension SPTScale: SPTObservableComponent {
    
    init(x: Float, y: Float, z: Float) {
        self.init(xyz: .init(x: x, y: y, z: z))
    }
    
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
    
    static func onDidEmergeSink(object: SPTObject, callback: @escaping DidEmergeCallback) -> SPTAnySubscription {
        
        let subscription = DidEmergeSubscription(observer: callback)
        
        let token = SPTScaleAddDidEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())

        subscription.canceller = { SPTScaleRemoveDidEmergeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTScaleAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTScaleRemoveWillChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onDidChangeSink(object: SPTObject, callback: @escaping DidChangeCallback) -> SPTAnySubscription {
        
        let subscription = DidChangeSubscription(observer: callback)
        
        let token = SPTScaleAddDidChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTScaleRemoveDidChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTScaleAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTScaleRemoveWillPerishObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
}
