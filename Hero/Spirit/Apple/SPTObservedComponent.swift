//
//  SPTObservedComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 14.08.22.
//

import Foundation
import Combine


@propertyWrapper
@dynamicMemberLookup
class SPTObservedComponent<C> where C: SPTObservableComponent {
    
    let object: SPTObject
    let binding: SPTObjectBinding<C>
    var willChangeSubscription: SPTAnySubscription?

    init(object: SPTObject) {
        self.object = object
        
        binding = SPTObjectBinding(value: C.get(object: object), setter: { newValue in
            C.update(newValue, object: object)
        })
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [weak self] newValue in
            self?.binding.onWillChange(newValue: newValue)
        }

    }
 
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<C, Subject>) -> SPTObjectBinding<Subject> {
        binding[dynamicMember: keyPath]
    }
    
    var publisher: ObservableObjectPublisher? {
        set { binding.publisher = newValue }
        get { binding.publisher }
    }
    
    var wrappedValue: C {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTObjectBinding<C> {
        binding
    }
    
}


@propertyWrapper
@dynamicMemberLookup
class SPTObservedOptionalComponent<C> where C: SPTObservableComponent {
    
    let object: SPTObject
    let binding: SPTObjectBinding<C?>
    var willEmergeSubscription: SPTAnySubscription?
    var willChangeSubscription: SPTAnySubscription?
    var willPerishSubscription: SPTAnySubscription?

    init(object: SPTObject) {
        self.object = object
        
        binding = SPTObjectBinding(value: C.tryGet(object: object), setter: { newValue in
            if let newValue = newValue {
                C.makeOrUpdate(newValue, object: object)
            } else {
                C.destroy(object: object)
            }
        })
        
        willEmergeSubscription = C.onWillEmergeSink(object: object) { [weak self] newValue in
            self?.binding.onWillChange(newValue: newValue)
        }
        
        willChangeSubscription = C.onWillChangeSink(object: object) { [weak self] newValue in
            self?.binding.onWillChange(newValue: newValue)
        }

        willPerishSubscription = C.onWillPerishSink(object: object) { [weak self] in
            self?.binding.onWillChange(newValue: nil)
        }
    }
 
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<C?, Subject>) -> SPTObjectBinding<Subject> {
        binding[dynamicMember: keyPath]
    }
    
    var publisher: ObservableObjectPublisher? {
        set { binding.publisher = newValue }
        get { binding.publisher }
    }
    
    var wrappedValue: C? {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTObjectBinding<C?> {
        binding
    }
    
}
