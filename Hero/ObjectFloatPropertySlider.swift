//
//  ObjectFloatPropertySlider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.05.23.
//

import SwiftUI

struct ObjectFloatPropertySlider: View {
    
    @Binding var value: Float
    
    @EnvironmentObject private var userInteractionState: UserInteractionState
    
    init(value: Binding<Float>) {
        _value = value
    }
    
    var body: some View {
        FloatSlider(value: $value) { isEditing in
            userInteractionState.isEditing = isEditing
        }
    }
}
