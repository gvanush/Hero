//
//  IntegerField.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.02.22.
//

import SwiftUI

struct IntegerField<T: FixedWidthInteger>: View {
    
    @Binding public var value: T
    let range: ClosedRange<T>
    
    init(value: Binding<T>, range: ClosedRange<T> = T.min...T.max) {
        _value = value
        self.range = range
    }
    
    var body: some View {
        Stepper(value: $value, in: range) {
            Text(String(value))
                .foregroundColor(.secondary)
                .padding(.leading, 4.0)
        }
        .frame(maxWidth: .infinity)
        .padding(4.0)
        .background(Material.thin)
        .cornerRadius(11.0)
        .shadow(radius: 1.0)
    }
    
}


struct IntField_Previews: PreviewProvider {

    struct ContainerView: View {

        @State var value: Int = 0

        var body: some View {
            IntegerField(value: $value, range: 0...5)
                .padding()
        }
    }

    static var previews: some View {
        ContainerView()
    }
}
