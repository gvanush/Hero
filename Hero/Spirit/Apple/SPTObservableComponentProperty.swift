//
//  SPTObservableComponentProperty.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.04.23.
//

import SwiftUI


@dynamicMemberLookup
class SPTObservableComponentProperty<C, V>: ObservableObject
where C: SPTInspectableComponent, V: Equatable {
    
    let object: SPTObject
    let propertyKeyPath: WritableKeyPath<C, V>
    private var willChangeSubscription: SPTAnySubscription?
    private var cachedValue: V
    
    init(object: SPTObject, keyPath: WritableKeyPath<C, V>) {
        self.object = object
        self.propertyKeyPath = keyPath
        self.cachedValue = C.get(object: object)[keyPath: keyPath]

        willChangeSubscription = C.onWillChangeSink(object: object) { [unowned self] newValue in
            if self.cachedValue != newValue[keyPath: keyPath] {
                self.cachedValue = newValue[keyPath: keyPath]
            }
        }
    }
    
    subscript<T>(dynamicMember keyPath: WritableKeyPath<V, T>) -> T {
        get {
            cachedValue[keyPath: keyPath]
        }
        set {
            var component = C.get(object: object)
            component[keyPath: propertyKeyPath.appending(path: keyPath)] = newValue
            C.update(component, object: object)
        }
    }
    
    var value: V {
        get {
            cachedValue
        }
        set {
            var component = C.get(object: object)
            component[keyPath: propertyKeyPath] = newValue
            C.update(component, object: object)
        }
    }
    
}
