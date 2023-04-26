//
//  SPTObservedComponent.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.04.23.
//

import SwiftUI


@propertyWrapper
class SPTObservedComponent<C>: ObservableObject
where C: SPTObservableComponent {
    
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
    
    var wrappedValue: C {
        set {
            C.update(newValue, object: object)
        }
        get { cachedValue }
    }
    
    var projectedValue: Binding<C> {
        .init {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }
    }
    
}


