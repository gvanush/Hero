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
class SPTObservedComponentProperty<C, V> where C: SPTObservableComponent, V: Equatable {
    
    let object: SPTObject
    let keyPath: WritableKeyPath<C, V>
    var willChangeSubscription: SPTAnySubscription?

    weak var publisher: ObservableObjectPublisher?
    
    init(object: SPTObject, keyPath: WritableKeyPath<C, V>) {
        self.object = object
        self.keyPath = keyPath
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [weak self] newValue in
            if C.get(object: object)[keyPath: keyPath] != newValue[keyPath: keyPath] {
                self?.publisher?.send()
            }
        }

    }
    
    var wrappedValue: V {
        set {
            var component = C.get(object: object)
            component[keyPath: keyPath] = newValue
            C.update(component, object: object)
        }
        get { C.get(object: object)[keyPath: keyPath] }
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
