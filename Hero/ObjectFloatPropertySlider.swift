//
//  ObjectFloatPropertySlider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.05.23.
//

import SwiftUI

struct ObjectFloatPropertySlider<C>: View
where C: SPTInspectableComponent {
    
    @StateObject private var value: SPTObservableComponentProperty<C, Float>
    
    @EnvironmentObject private var userInteractionState: UserInteractionState
    
    init(object: SPTObject, keyPath: WritableKeyPath<C, Float>) {
        _value = .init(wrappedValue: .init(object: object, keyPath: keyPath))
    }
    
    var body: some View {
        FloatSlider(value: $value.value) { isEditing in
            userInteractionState.isEditing = isEditing
        }
    }
}
