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
class SPTObservedAnimatorBinding<P> where P: SPTAnimatableProperty {
    
    let property: P
    let object: SPTObject
    private var willChangeSubscription: SPTAnySubscription?
    private var cachedValue: SPTAnimatorBinding

    weak var publisher: ObservableObjectPublisher?
    
    init(property: P, object: SPTObject) {
        self.property = property
        self.object = object
        self.cachedValue = property.getAnimatorBinding(object: object)
        
        willChangeSubscription = property.onAnimatorBindingWillChangeSink(object: object) { [unowned self] newValue in
            self.publisher?.send()
            self.cachedValue = newValue
        }

    }
    
    var wrappedValue: SPTAnimatorBinding {
        set { property.updateAnimatorBinding(newValue, object: object) }
        get { cachedValue }
    }
    
}


@propertyWrapper
class SPTObservedOptionalAnimatorBinding<P> where P: SPTAnimatableProperty {
    
    let property: P
    let object: SPTObject
    private var didEmergeSubscription: SPTAnySubscription?
    private var willChangeSubscription: SPTAnySubscription?
    private var willPerishSubscription: SPTAnySubscription?
    private var cachedValue: SPTAnimatorBinding?
    
    weak var publisher: ObservableObjectPublisher?
    
    init(property: P, object: SPTObject) {
        self.property = property
        self.object = object
        self.cachedValue = property.tryGetAnimatorBinding(object: object)
        didEmergeSubscription = property.onAnimatorBindingDidEmergeSink(object: object) { [weak self] newValue in
            self!.cachedValue = newValue
            self!.publisher?.send()
        }
        
        willChangeSubscription = property.onAnimatorBindingWillChangeSink(object: object) { [weak self] newValue in
            self!.publisher?.send()
            self!.cachedValue = newValue
        }

        willPerishSubscription = property.onAnimatorBindingWillPerishSink(object: object) { [weak self] in
            self!.publisher?.send()
            self!.cachedValue = nil
        }
    }
    
    var wrappedValue: SPTAnimatorBinding? {
        set {
            if let newValue {
                property.bindOrUpdate(newValue, object: object)
            } else {
                property.unbindAnimator(object: object)
            }
        }
        get { cachedValue }
    }
    
}
