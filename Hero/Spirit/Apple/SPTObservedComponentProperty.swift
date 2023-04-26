//
//  SPTObservedComponentProperty.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.04.23.
//

import SwiftUI


@propertyWrapper
class SPTObservedComponentProperty<C, V>: ObservableObject
where C: SPTObservableComponent, V: Equatable {
    
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
    
    var wrappedValue: V {
        set {
            var component = C.get(object: object)
            component[keyPath: keyPath] = newValue
            C.update(component, object: object)
        }
        get { cachedValue }
    }
    
    var projectedValue: Binding<V> {
        .init {
            self.wrappedValue
        } set: {
            self.wrappedValue = $0
        }

    }
    
}
