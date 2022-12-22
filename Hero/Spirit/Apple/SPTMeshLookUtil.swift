//
//  SPTMeshLookUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 01.09.22.
//

import Foundation

extension SPTMeshShading: Equatable {
    
    public static func == (lhs: SPTMeshShading, rhs: SPTMeshShading) -> Bool {
        SPTMeshShadingEqual(lhs, rhs)
    }
    
}

extension SPTMeshLook: SPTObservableComponent {
    
    init(material: SPTPlainColorMaterial, meshId: SPTMeshId, categories: SPTLookCategories = kSPTLookCategoriesAll) {
        self.init(shading: .init(type: .plainColor, .init(plainColor: material)), meshId: meshId, categories: categories)
    }
    
    init(material: SPTPhongMaterial, meshId: SPTMeshId, categories: SPTLookCategories = kSPTLookCategoriesAll) {
        self.init(shading: .init(type: .blinnPhong, .init(blinnPhong: material)), meshId: meshId, categories: categories)
    }
    
    public static func == (lhs: SPTMeshLook, rhs: SPTMeshLook) -> Bool {
        SPTMeshLookEqual(lhs, rhs)
    }
    
    static func make(_ component: SPTMeshLook, object: SPTObject) {
        SPTMeshLookMake(object, component)
    }
    
    static func makeOrUpdate(_ component: SPTMeshLook, object: SPTObject) {
        if SPTMeshLookExists(object) {
            SPTMeshLookUpdate(object, component)
        } else {
            SPTMeshLookMake(object, component)
        }
    }
    
    static func update(_ component: SPTMeshLook, object: SPTObject) {
        SPTMeshLookUpdate(object, component)
    }
    
    static func destroy(object: SPTObject) {
        SPTMeshLookDestroy(object)
    }
    
    static func get(object: SPTObject) -> SPTMeshLook {
        SPTMeshLookGet(object)
    }
    
    static func tryGet(object: SPTObject) -> SPTMeshLook? {
        SPTMeshLookTryGet(object)?.pointee
    }
    
    static func onDidEmergeSink(object: SPTObject, callback: @escaping DidEmergeCallback) -> SPTAnySubscription {
        let subscription = DidEmergeSubscription(observer: callback)
        
        let token = SPTMeshLookAddDidEmergeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidEmergeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTMeshLookRemoveDidEmergeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription {
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTMeshLookAddWillChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<WillChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTMeshLookRemoveWillChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onDidChangeSink(object: SPTObject, callback: @escaping DidChangeCallback) -> SPTAnySubscription {
        let subscription = WillChangeSubscription(observer: callback)
        
        let token = SPTMeshLookAddDidChangeObserver(object, { newValue, userInfo in
            let subscription = Unmanaged<DidChangeSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer(newValue)
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTMeshLookRemoveDidChangeObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription {
        let subscription = WillPerishSubscription(observer: callback)
        
        let token = SPTMeshLookAddWillPerishObserver(object, { userInfo in
            let subscription = Unmanaged<WillPerishSubscription>.fromOpaque(userInfo!).takeUnretainedValue()
            subscription.observer()
        }, Unmanaged.passUnretained(subscription).toOpaque())
        
        subscription.canceller = { SPTMeshLookRemoveWillPerishObserver(object, token) }
        
        return subscription.eraseToAnySubscription()
    }
    
}
