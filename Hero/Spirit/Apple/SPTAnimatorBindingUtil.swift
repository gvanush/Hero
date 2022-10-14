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
    var willChangeSubscription: SPTAnySubscription?

    weak var publisher: ObservableObjectPublisher?
    
    init(property: P, object: SPTObject) {
        self.property = property
        self.object = object
        
        willChangeSubscription = property.onAnimatorBindingWillChangeSink(object: object) { [weak self] _ in
            self?.publisher?.send()
        }

    }
    
    var wrappedValue: SPTAnimatorBinding {
        set { property.updateAnimatorBinding(newValue, object: object) }
        get { property.getAnimatorBinding(object: object) }
    }
    
}


@propertyWrapper
class SPTObservedOptionalAnimatorBinding<P> where P: SPTAnimatableProperty {
    
    let property: P
    let object: SPTObject
    var willEmergeSubscription: SPTAnySubscription?
    var willChangeSubscription: SPTAnySubscription?
    var willPerishSubscription: SPTAnySubscription?

    weak var publisher: ObservableObjectPublisher?
    
    init(property: P, object: SPTObject) {
        self.property = property
        self.object = object
        
        willEmergeSubscription = property.onAnimatorBindingWillEmergeSink(object: object) { [weak self] newValue in
            self?.publisher?.send()
        }
        
        willChangeSubscription = property.onAnimatorBindingWillChangeSink(object: object) { [weak self] newValue in
            self?.publisher?.send()
        }

        willPerishSubscription = property.onAnimatorBindingWillPerishSink(object: object) { [weak self] in
            self?.publisher?.send()
        }
    }
    
    var wrappedValue: SPTAnimatorBinding? {
        set {
            if let newValue = newValue {
                property.bindOrUpdate(newValue, object: object)
            } else {
                property.unbindAnimator(object: object)
            }
        }
        get { property.tryGetAnimatorBinding(object: object) }
    }
    
}
