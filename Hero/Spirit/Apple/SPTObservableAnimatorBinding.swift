//
//  SPTObservableAnimatorBinding.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.05.23.
//

import Foundation


@dynamicMemberLookup
class SPTObservableAnimatorBinding<P>: ObservableObject
where P: SPTAnimatableProperty {
    
    let property: P
    let object: SPTObject
    private var cachedValue: SPTAnimatorBinding?
    private var didEmergeSubscription: SPTAnySubscription?
    private var willChangeSubscription: SPTAnySubscription?
    private var willPerishSubscription: SPTAnySubscription?
    
    init(property: P, object: SPTObject) {
        self.property = property
        self.object = object
        self.cachedValue = property.tryGetAnimatorBinding(object: object)
        
        didEmergeSubscription = property.onAnimatorBindingDidEmergeSink(object: object) { [unowned self] newValue in
            objectWillChange.send()
            self.cachedValue = newValue
        }
        
        willChangeSubscription = property.onAnimatorBindingWillChangeSink(object: object) { [unowned self] newValue in
            objectWillChange.send()
            self.cachedValue = newValue
        }
        
        willPerishSubscription = property.onAnimatorBindingWillPerishSink(object: object) { [unowned self] in
            objectWillChange.send()
            self.cachedValue = nil
        }
        
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<SPTAnimatorBinding, T>) -> T {
        get {
            cachedValue![keyPath: keyPath]
        }
        set {
            var value = cachedValue!
            value[keyPath: keyPath] = newValue
            property.updateAnimatorBinding(value, object: object)
        }
    }
    
    var value: SPTAnimatorBinding? {
        get {
            cachedValue
        }
        set {
            if let newValue {
                property.bindOrUpdate(newValue, object: object)
            } else {
                property.unbindAnimator(object: object)
            }
        }
    }
    
}


