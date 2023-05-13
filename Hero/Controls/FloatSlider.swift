//
//  FloatSlider.swift
//  Hero
//
//  Created by Vanush Grigoryan on 28.08.22.
//

import SwiftUI


struct FloatSlider: View {
    
    @Binding var value: Float
    let range: ClosedRange<Float> = 0...1
    let onEditingChanged: (Bool) -> Void
    
    init(value: Binding<Float>, onEditingChanged: @escaping (Bool) -> Void = { _ in }) {
        _value = value
        self.onEditingChanged = onEditingChanged
    }
    
    @State private var isEditing = false
    
    var body: some View {
        VStack(spacing: 4.0) {
            Text(String(format: "%.2f", value))
                .foregroundColor(.controlValue)
            Slider(value: $value, in: range, onEditingChanged: { isEditing in
                self.isEditing = isEditing
                onEditingChanged(isEditing)
            })
            .padding(.horizontal, 16.0)
        }
        .padding(Self.padding)
        .frame(maxWidth: .infinity)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
        .onDisappear {
            if isEditing {
                onEditingChanged(false)
            }
        }
    }
    
    static let padding = 4.0
    static let cornerRadius = 11.0
}


struct FloatSlider_Previews: PreviewProvider {
    
    struct ContanerView: View {
        
        @State var value: Float = 0.5
        
        var body: some View {
            FloatSlider(value: $value)
        }
    }
    
    static var previews: some View {
        ContanerView()
            .padding()
    }
}
