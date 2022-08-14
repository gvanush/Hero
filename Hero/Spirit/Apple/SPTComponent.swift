//
//  SPTComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import Foundation


protocol SPTComponent: Equatable {
    
    typealias WillEmergeCallback = (Self) -> Void
    typealias WillEmergeSubscription = SPTSubscription<WillEmergeCallback, SPTComponentObserverToken>
    
    typealias WillChangeCallback = (Self) -> Void
    typealias WillChangeSubscription = SPTSubscription<WillChangeCallback, SPTComponentObserverToken>
    
    typealias WillPerishCallback = () -> Void
    typealias WillPerishSubscription = SPTSubscription<WillPerishCallback, SPTComponentObserverToken>
    
    static func makeOrUpdate(_ component: Self, object: SPTObject)
    
    static func update(_ component: Self, object: SPTObject)
    
    static func destroy(object: SPTObject)
    
    static func get(object: SPTObject) -> Self
    
    static func tryGet(object: SPTObject) -> Self?
    
    static func onWillEmergeSink(object: SPTObject, callback: @escaping WillEmergeCallback) -> SPTAnySubscription
    
    static func onWillChangeSink(object: SPTObject, callback: @escaping WillChangeCallback) -> SPTAnySubscription
    
    static func onWillPerishSink(object: SPTObject, callback: @escaping WillPerishCallback) -> SPTAnySubscription
    
}
