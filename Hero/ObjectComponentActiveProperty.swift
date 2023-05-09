//
//  ObjectComponentActiveProperty.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.04.23.
//

import SwiftUI


@propertyWrapper
struct ObjectComponentActiveProperty<P>: DynamicProperty
where P: RawRepresentable, P.RawValue == Int {
    
    let object: SPTObject
    let componentId: AnyHashable
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject, componentId: AnyHashable) {
        self.object = object
        self.componentId = componentId
    }
    
    var wrappedValue: P {
        nonmutating set {
            editingParams[componentId: componentId, object].activePropertyIndex = newValue.rawValue
        }
        get {
            .init(rawValue: editingParams[componentId: componentId, object].activePropertyIndex)!
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
