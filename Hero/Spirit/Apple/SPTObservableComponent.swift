//
//  SPTObservableComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.04.23.
//

import SwiftUI


@dynamicMemberLookup
class SPTObservableComponent<C>: ObservableObject
where C: SPTInspectableComponent {
    
    let object: SPTObject
    private var willChangeSubscription: SPTAnySubscription?
    private var cachedValue: C
    
    init(object: SPTObject) {
        self.object = object
        self.cachedValue = C.get(object: object)

        willChangeSubscription = C.onWillChangeSink(object: object) { [unowned self] in
            self.objectWillChange.send()
            self.cachedValue = $0
        }
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<C, T>) -> T {
        get {
            cachedValue[keyPath: keyPath]
        }
        set {
            var value = cachedValue
            value[keyPath: keyPath] = newValue
            C.update(value, object: object)
        }
    }
    
    var value: C {
        get {
            cachedValue
        }
        set {
            C.update(newValue, object: object)
        }
    }
    
}


