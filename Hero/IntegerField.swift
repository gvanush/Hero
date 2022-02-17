//
//  IntegerField.swift
//  Hero
//
//  Created by Vanush Grigoryan on 07.02.22.
//

import SwiftUI

struct IntegerField<T: FixedWidthInteger>: View {
    
    @Binding var value: T
    let range: ClosedRange<T>
    let deltaOptions: Array<T>
    @State private var delta: T = 1
    
    init(value: Binding<T>, range: ClosedRange<T> = T.min...T.max, deltaOptions: Array<T> = [1]) {
        _value = value
        self.range = range
        self.deltaOptions = (deltaOptions.isEmpty ? [1] : deltaOptions)
    }
    
    var body: some View {
        VStack {
            ZStack {
                HStack {
                    Text(String(value))
                        .foregroundColor(.controlValueColor)
                }
                if deltaOptions.count > 1 {
                    HStack {
                        DeltaPicker(delta: $delta, deltaOptions: deltaOptions)
                        Spacer()
                    }
                }
            }
            .padding(4.0)
            Spacer(minLength: 0.0)
            HStack(spacing: 0.0) {
                Spacer()
                editButton(systemIcon: "minus", action: { substractValue(delta: delta) })
                    .disabled(value == range.lowerBound)
                Divider()
                editButton(systemIcon: "plus", action: { addToValue(delta: delta) })
                    .disabled(value == range.upperBound)
                Spacer()
            }
            .tint(Color.objectSelectionColor)
        }
        .frame(maxWidth: .infinity, maxHeight: 75.0)
        .background(Material.thin)
        .cornerRadius(11.0)
        .shadow(radius: 1.0)
    }
    
    func editButton(systemIcon: String, action: @escaping () -> Void) -> some View {
        Button(action: action, label: {
            Image(systemName: systemIcon)
                .padding(.horizontal, 20.0)
                .frame(maxHeight: .infinity)
        })
    }
    
    func addToValue(delta: T) -> Void {
        let result = value.addingReportingOverflow(delta)
        if result.overflow {
            value = delta > 0 ? range.upperBound : range.lowerBound
        } else {
            value = result.partialValue.clamped(min: range.lowerBound, max: range.upperBound)
        }
    }
    
    func substractValue(delta: T) -> Void {
        let result = value.subtractingReportingOverflow(delta)
        if result.overflow {
            value = delta < 0 ? range.upperBound : range.lowerBound
        } else {
            value = result.partialValue.clamped(min: range.lowerBound, max: range.upperBound)
        }
    }
}


fileprivate struct DeltaPicker<T: FixedWidthInteger>: View {
    
    @Binding var delta: T
    let deltaOptions: Array<T>
    
    var body: some View {
        Picker("", selection: $delta) {
            ForEach(deltaOptions, id: \.self) { delta in
                Text("∆\(String(delta))")
            }
        }
        .accentColor(.secondary)
        .frame(width: 50.0, height: 29.0, alignment: .center)
        .overlay {
            RoundedRectangle(cornerRadius: 7.0)
                .strokeBorder(Color.tertiary, lineWidth: 1)
        }
        .pickerStyle(.menu)
    }
    
}


struct IntField_Previews: PreviewProvider {

    struct ContainerView: View {

        @State var value: Int = 0

        var body: some View {
            IntegerField(value: $value, range: 0...1000, deltaOptions: [1, 5, 10, 100])
                .padding()
        }
    }

    static var previews: some View {
        ContainerView()
    }
}
