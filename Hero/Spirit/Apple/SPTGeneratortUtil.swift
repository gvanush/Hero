//
//  SPTGeneratortUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.03.22.
//

import Foundation


extension SPTGenerator: SPTObservableComponent {
    
    init(quantity: SPTGeneratorQuantityType, sourceMeshId: SPTMeshId) {
        self.init(arrangement: .init(variantTag: .linear, .init(linear: .init(axis: .X))), sourceMeshId: sourceMeshId, quantity: quantity)
    }
    
    public static func == (lhs: SPTGenerator, rhs: SPTGenerator) -> Bool {
        SPTGeneratorEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTGenerator, object: SPTObject) {
        SPTGeneratorMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTGenerator, object: SPTObject) {
        if SPTGeneratorExists(object) {
            SPTGeneratorUpdate(object, component)
        } else {
            SPTGeneratorMake(object, component)
        }
    }
    
    static func update(_ component: SPTGenerator, object: SPTObject) {
        SPTGeneratorUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTGeneratorDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTGenerator {
        SPTGeneratorGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTGenerator? {
        SPTGeneratorTryGet(object)?.pointee
    }
    
    static func onWillEmergeSink(object: SPTObject, callback: @escaping WillEmergeCallback) -> SPTAnySubscription {
        
        let subscription = WillEmergeSubscription(observer: callback)
        
        let token = SPTGeneratorAddWillEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTGeneratorRemoveWillEmergeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTGeneratorAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTGeneratorRemoveWillChangeObserver(object, token) }
        
        return subscription
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTGeneratorAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTGeneratorRemoveWillPerishObserver(object, token) }
        
        return subscription
    }
    
}


extension SPTArrangement: Equatable {
    
    public static func == (lhs: SPTArrangement, rhs: SPTArrangement) -> Bool {
        SPTArrangementEqual(lhs, rhs)
    }
    
}

extension SPTPointArrangement: Equatable {
    
    public static func == (lhs: SPTPointArrangement, rhs: SPTPointArrangement) -> Bool {
        SPTPointArrangementEqual(lhs, rhs)
    }
    
}


extension SPTLinearArrangement: Equatable {
    
    public static func == (lhs: SPTLinearArrangement, rhs: SPTLinearArrangement) -> Bool {
        SPTLinearArrangementEqual(lhs, rhs)
    }
    
}


extension SPTPlanarArrangement: Equatable {
    
    public static func == (lhs: SPTPlanarArrangement, rhs: SPTPlanarArrangement) -> Bool {
        SPTPlanarArrangementEqual(lhs, rhs)
    }
    
}


extension SPTSpatialArrangement: Equatable {
    
    public static func == (lhs: SPTSpatialArrangement, rhs: SPTSpatialArrangement) -> Bool {
        SPTSpatialArrangementEqual(lhs, rhs)
    }
    
}
