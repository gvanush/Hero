//
//  ObjectElementActiveProperty.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.04.23.
//

import SwiftUI


@propertyWrapper
struct ObjectElementActiveProperty<P>: DynamicProperty
where P: RawRepresentable, P.RawValue == Int {
    
    let object: SPTObject
    let elementId: AnyHashable
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject, elementId: AnyHashable) {
        self.object = object
        self.elementId = elementId
    }
    
    var wrappedValue: P {
        nonmutating set {
            editingParams[elementId: elementId, object].activePropertyIndex = newValue.rawValue
        }
        get {
            .init(rawValue: editingParams[elementId: elementId, object].activePropertyIndex)!
        }
    }
    
    var projectedValue: Binding<P> {
        .init {
            wrappedValue
        } set: {
            wrappedValue = $0
        }
    }
    
}
