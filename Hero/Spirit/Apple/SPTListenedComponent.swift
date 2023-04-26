//
//  SPTListenedComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import Foundation
import Combine


@propertyWrapper
class SPTListenedComponent<C> where C: SPTObservableComponent {
    
    let object: SPTObject
    private var willChangeSubscription: SPTAnySubscription?
    private var cachedValue: C

    weak var publisher: ObservableObjectPublisher?
    
    init(object: SPTObject) {
        self.object = object
        self.cachedValue = C.get(object: object)
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [unowned self] newValue in
            self.publisher?.send()
            self.cachedValue = newValue
        }

    }
    
    var wrappedValue: C {
        set { C.update(newValue, object: object) }
        get { cachedValue }
    }
    
}

class SPTListenableComponentProperty<C, V>: ObservableObject where C: SPTObservableComponent, V: Equatable {
    
    let object: SPTObject
    let keyPath: WritableKeyPath<C, V>
    private var willChangeSubscription: SPTAnySubscription?
    private var cachedValue: V
    
    init(object: SPTObject, keyPath: WritableKeyPath<C, V>) {
        self.object = object
        self.keyPath = keyPath
        self.cachedValue = C.get(object: object)[keyPath: keyPath]
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [unowned self] newValue in
            if self.cachedValue != newValue[keyPath: keyPath] {
                self.objectWillChange.send()
                self.cachedValue = newValue[keyPath: keyPath]
            }
        }

    }
    
    var value: V {
        set {
            var component = C.get(object: object)
            component[keyPath: keyPath] = newValue
            C.update(component, object: object)
        }
        get { cachedValue }
    }
    
}

@propertyWrapper
class SPTListenedComponentProperty<C, V> where C: SPTObservableComponent, V: Equatable {
    
    let object: SPTObject
    let keyPath: WritableKeyPath<C, V>
    private var willChangeSubscription: SPTAnySubscription?
    private var cachedValue: V
    
    weak var publisher: ObservableObjectPublisher?
    
    init(object: SPTObject, keyPath: WritableKeyPath<C, V>) {
        self.object = object
        self.keyPath = keyPath
        self.cachedValue = C.get(object: object)[keyPath: keyPath]
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [weak self] newValue in
            if self!.cachedValue != newValue[keyPath: keyPath] {
                self!.publisher?.send()
                self!.cachedValue = newValue[keyPath: keyPath]
            }
        }

    }
    
    var wrappedValue: V {
        set {
            var component = C.get(object: object)
            component[keyPath: keyPath] = newValue
            C.update(component, object: object)
        }
        get { cachedValue }
    }
    
}


@propertyWrapper
class SPTListenedOptionalComponent<C> where C: SPTObservableComponent {
    
    let object: SPTObject
    private var didEmergeSubscription: SPTAnySubscription?
    private var willChangeSubscription: SPTAnySubscription?
    private var willPerishSubscription: SPTAnySubscription?
    private var cachedValue: C?
    
    weak var publisher: ObservableObjectPublisher?
    
    init(object: SPTObject) {
        self.object = object
        self.cachedValue = C.tryGet(object: object)
        
        didEmergeSubscription = C.onDidEmergeSink(object: object) { [weak self] newValue in
            self!.cachedValue = newValue
            self!.publisher?.send()
        }
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [weak self] newValue in
            self!.publisher?.send()
            self!.cachedValue = newValue
        }

        willPerishSubscription = C.onWillPerishSink(object: object) { [weak self] in
            self!.publisher?.send()
            self!.cachedValue = nil
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
            cachedValue
        }
    }
    
}
