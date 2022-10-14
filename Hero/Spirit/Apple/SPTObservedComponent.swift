//
//  SPTObservedComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import Foundation
import Combine


@propertyWrapper
class SPTObservedComponent<C> where C: SPTObservableComponent {
    
    let object: SPTObject
    var willChangeSubscription: SPTAnySubscription?

    weak var publisher: ObservableObjectPublisher?
    
    init(object: SPTObject) {
        self.object = object
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [weak self] newValue in
            self?.publisher?.send()
        }

    }
    
    var wrappedValue: C {
        set { C.update(newValue, object: object) }
        get { C.get(object: object) }
    }
    
}


@propertyWrapper
class SPTObservedOptionalComponent<C> where C: SPTObservableComponent {
    
    let object: SPTObject
    var willEmergeSubscription: SPTAnySubscription?
    var willChangeSubscription: SPTAnySubscription?
    var willPerishSubscription: SPTAnySubscription?

    weak var publisher: ObservableObjectPublisher?
    
    init(object: SPTObject) {
        self.object = object
        
        willEmergeSubscription = C.onWillEmergeSink(object: object) { [weak self] newValue in
            self?.publisher?.send()
        }
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [weak self] newValue in
            self?.publisher?.send()
        }

        willPerishSubscription = C.onWillPerishSink(object: object) { [weak self] in
            self?.publisher?.send()
        }
    }
    
    var wrappedValue: C? {
        set {
            if let newValue = newValue {
                C.makeOrUpdate(newValue, object: object)
            } else {
                C.destroy(object: object)
            }
        }
        get {
            C.tryGet(object: object)
        }
    }
    
}
