//
//  SPTOrientationUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.03.22.
//

import Foundation


extension SPTOrientation: SPTObservableComponent {
    
    init(x: Float = 0.0, y: Float = 0.0, z: Float = 0.0, order: SPTEulerOrder = .XYZ) {
        self.init(euler: .init(rotation: .init(x: x, y: y, z: z), order: order))
    }
    
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
    
    static func onDidEmergeSink(object: SPTObject, callback: @escaping DidEmergeCallback) -> SPTAnySubscription {
        
        let subscription = DidEmergeSubscription(observer: callback)
        
        let token = SPTOrientationAddDidEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveDidEmergeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTOrientationAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveWillChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onDidChangeSink(object: SPTObject, callback: @escaping DidChangeCallback) -> SPTAnySubscription {
        
        let subscription = DidChangeSubscription(observer: callback)
        
        let token = SPTOrientationAddDidChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveDidChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTOrientationAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTOrientationRemoveWillPerishObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
}
