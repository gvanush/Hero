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
    
    var body: some View {
        VStack(spacing: 4.0) {
            Text(String(format: "%.2f", value))
                .foregroundColor(.controlValue)
            Slider(value: $value, in: range)
                .tint(.black)
                .padding(.horizontal, 16.0)
        }
        .padding(Self.padding)
        .frame(maxWidth: .infinity)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
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
