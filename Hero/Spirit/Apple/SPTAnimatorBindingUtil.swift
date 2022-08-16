//
//  SPTAnimatorBindingUtil.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.08.22.
//

import Foundation
import Combine


extension SPTAnimatorBinding: Equatable {
    
    public static func == (lhs: SPTAnimatorBinding, rhs: SPTAnimatorBinding) -> Bool {
        SPTAnimatorBindingEqual(lhs, rhs)
    }
    
}


@propertyWrapper
@dynamicMemberLookup
class SPTObservedAnimatorBinding<P> where P: SPTAnimatableProperty {
    
    let property: P
    let object: SPTObject
    let binding: SPTObjectBinding<SPTAnimatorBinding>
    var willChangeSubscription: SPTAnySubscription?

    init(property: P, object: SPTObject) {
        self.property = property
        self.object = object
        
        binding = SPTObjectBinding(value: property.getAnimatorBinding(object: object), setter: { newValue in
            property.updateAnimatorBinding(newValue, object: object)
        })
        
        willChangeSubscription = property.onAnimatorBindingWillChangeSink(object: object) { [weak self] newValue in
            self?.binding.onWillChange(newValue: newValue)
        }

    }
 
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<SPTAnimatorBinding, Subject>) -> SPTObjectBinding<Subject> {
        binding[dynamicMember: keyPath]
    }
    
    var publisher: ObservableObjectPublisher? {
        set { binding.publisher = newValue }
        get { binding.publisher }
    }
    
    var wrappedValue: SPTAnimatorBinding {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTObjectBinding<SPTAnimatorBinding> {
        binding
    }
    
}


@propertyWrapper
@dynamicMemberLookup
class SPTObservedOptionalAnimatorBinding<P> where P: SPTAnimatableProperty {
    
    let property: P
    let object: SPTObject
    let binding: SPTObjectBinding<SPTAnimatorBinding?>
    var willEmergeSubscription: SPTAnySubscription?
    var willChangeSubscription: SPTAnySubscription?
    var willPerishSubscription: SPTAnySubscription?

    init(property: P, object: SPTObject) {
        self.property = property
        self.object = object
        
        binding = SPTObjectBinding(value: property.tryGetAnimatorBinding(object: object), setter: { newValue in
            if let newValue = newValue {
                property.bindOrUpdate(newValue, object: object)
            } else {
                property.unbindAnimator(object: object)
            }
        })
        
        willEmergeSubscription = property.onAnimatorBindingWillEmergeSink(object: object) { [weak self] newValue in
            self?.binding.onWillChange(newValue: newValue)
        }
        
        willChangeSubscription = property.onAnimatorBindingWillChangeSink(object: object) { [weak self] newValue in
            self?.binding.onWillChange(newValue: newValue)
        }

        willPerishSubscription = property.onAnimatorBindingWillPerishSink(object: object) { [weak self] in
            self?.binding.onWillChange(newValue: nil)
        }
    }
 
    subscript<Subject>(dynamicMember keyPath: WritableKeyPath<SPTAnimatorBinding?, Subject>) -> SPTObjectBinding<Subject> {
        binding[dynamicMember: keyPath]
    }
    
    var publisher: ObservableObjectPublisher? {
        set { binding.publisher = newValue }
        get { binding.publisher }
    }
    
    var wrappedValue: SPTAnimatorBinding? {
        set { binding.wrappedValue = newValue }
        get { binding.wrappedValue }
    }
    
    var projectedValue: SPTObjectBinding<SPTAnimatorBinding?> {
        binding
    }
    
}
