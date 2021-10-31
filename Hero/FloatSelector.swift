//
//  FloatSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.10.21.
//

import SwiftUI

@propertyWrapper
class InterpolableValue<T>: DynamicProperty {
    
    @Binding private var value: T
    
    init(value: Binding<T>) {
        _value = value
    }
    
    var projectedValue: Binding<T> {
        $value
    }
    
    var wrappedValue: T {
        get {
            value
        }
        set {
            value = newValue
        }
    }
}

struct FloatSelector: View {
    
    @Binding var value: Double
    @State private var baseValue: Double
    @GestureState private var dragDeltaValue = 0.0
    @State private var isScrolling = false
    
    init(value: Binding<Double>) {
        _value = value
        baseValue = value.wrappedValue
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    Text(String.init(format: "%.2f", value))
                        .foregroundColor(.secondary)
                    Spacer()
                }
                HStack {
                    Spacer()
                    stepper()
                }
            }
            ZStack {
                Color.secondary
                    .frame(idealWidth: Self.pointerWidth, maxHeight: .infinity)
                    .fixedSize(horizontal: true, vertical: false)
                Ruler(unitSize: Self.rulerUnitSize, additionalUnitsCount: Self.rulerAdditionalUnitCount)
                    .offset(x: -fmod(value, Double(Self.rulerAdditionalUnitCount)) * Self.rulerUnitSize, y: 0.0)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture())
        }
        .frame(maxWidth: .infinity, idealHeight: Self.height)
        .fixedSize(horizontal: false, vertical: true)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius, corners: [.topLeft, .topRight])
        .overlay(RoundedCorner(radius: Self.cornerRadius, corners: [.topLeft, .topRight]).stroke(Color.orange, lineWidth: 1.0))
        .onChange(of: dragDeltaValue) { newDragDeltaValue in
            value = baseValue + newDragDeltaValue
        }
        .onChange(of: value) { newValue in
            if !isScrolling {
                baseValue = newValue
            }
        }
    }
    
    func stepper() -> some View {
        Stepper(value: $value, label: { EmptyView() })
            .opacity(isScrolling ? 0.0 : 1.0)
            .labelsHidden()
            .padding(Self.stepperPadding)
    }
    
    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .updating($dragDeltaValue, body: { dragValue, state, _ in
                state = deltaValueForDisplacement(dragValue.translation.width)
            })
            .onChanged { _ in
                withAnimation {
                    isScrolling = true
                }
            }
            .onEnded { dragValue in
                baseValue += deltaValueForDisplacement(dragValue.translation.width)
                withAnimation {
                    isScrolling = false
                }
            }
    }
    
    private func deltaValueForDisplacement(_ displacement: CGFloat) -> Double {
        -displacement / Self.rulerUnitSize
    }
    
    static let height = 75.0
    static let stepperPadding = 4.0
    static let cornerRadius = 11.0
    static let rulerUnitSize = 10.0
    static let rulerAdditionalUnitCount = 10
    static let pointerWidth = 1.0
    static let pointerHeight = 32.0
    static let scrollDecaySpeed = 100.0
}

fileprivate struct Ruler: View {
    
    let unitSize: CGFloat
    let additionalUnitsCount: Int
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                var number = 0
                
                let midX = 0.5 * geometry.size.width
                
                path.move(to: CGPoint(x: midX, y: geometry.size.height))
                path.addLine(to: CGPoint(x: midX, y: geometry.size.height - heightFor(number)))
                
                var baseX = 0.0
                let halfWidth = CGFloat(additionalUnitsCount) * unitSize + 0.5 * geometry.size.width
                while baseX <= halfWidth {
                    number += 1
                    baseX = Double(number) * unitSize
                    
                    let y = geometry.size.height - heightFor(number)
                    
                    for x in [midX + baseX, midX - baseX] {
                        path.move(to: CGPoint(x: x, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                }
            }
            .stroke(lineWidth: 1.0)
        }
    }
    
    func heightFor(_ number: Int) -> CGFloat {
        if number % 10 == 0 { return Self.tensHeight }
        if number % 5 == 0 { return Self.fivesHeight }
        return Self.onesHeight
    }
    
    static let onesHeight = 8.0
    static let fivesHeight = 12.0
    static let tensHeight = 16.0
}

struct FloatSelector_Previews: PreviewProvider {
    static var previews: some View {
        FloatSelector(value: .constant(0.0))
            .padding(8.0)
    }
}