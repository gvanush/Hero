//
//  FloatField.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.10.21.
//

import SwiftUI

fileprivate struct Params {
    static let height = 75.0
    static let stepperPadding = 4.0
    static let cornerRadius = 11.0
    static let rulerUnitSize = 10.0
    static let rulerAdditionalUnitCount = 10
    static let pointerWidth = 1.0
    static let pointerHeight = 32.0
    static let scrollMinInitialSpeed = 100.0
}

struct FloatField: View {
    
    enum EditingState {
        case idle
        case dragging
        case scrolling
        case stepping
    }
    
    @Binding var value: Double
    @State private var state = EditingState.idle
    
    @State private var dragBaseValue = 0.0
    
    @State private var scrollAnimator: DisplayRefreshSync!
    @State private var scrollAnimationUtil = ScrollAnimationUtil()
    
    private let formatter: Formatter?
    typealias FormatterSubjectProvider = (Double) -> NSObject
    private let formatterSubjectProvider: FormatterSubjectProvider?
        
    init(value: Binding<Double>) {
        _value = value
        self.formatter = nil
        self.formatterSubjectProvider = nil
    }
    
    init(value: Binding<Double>, formatter: Formatter, formatterSubjectProvider: @escaping FormatterSubjectProvider) {
        _value = value
        self.formatter = formatter
        self.formatterSubjectProvider = formatterSubjectProvider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                HStack {
                    Spacer()
                    valueText
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
                    .frame(idealWidth: Params.pointerWidth, maxHeight: .infinity)
                    .fixedSize(horizontal: true, vertical: false)
                Ruler(unitSize: Params.rulerUnitSize, additionalUnitsCount: Params.rulerAdditionalUnitCount)
                    .offset(x: -fmod(value, Double(Params.rulerAdditionalUnitCount)) * Params.rulerUnitSize, y: 0.0)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture())
        }
        .frame(maxWidth: .infinity, idealHeight: Params.height)
        .fixedSize(horizontal: false, vertical: true)
        .background(Material.thin)
        .cornerRadius(Params.cornerRadius, corners: [.topLeft, .topRight])
        .overlay(BezierRoundedRectangle(radius: Params.cornerRadius, corners: [.topLeft, .topRight]).stroke(Color.orange, lineWidth: 1.0))
        .onAppear {
            scrollAnimator = DisplayRefreshSync(update: { time in
                self.value = scrollAnimationUtil.value(at: time)
            }, completion: {
                if state == .scrolling {
                    withAnimation {
                        state = .idle
                    }
                }
            })
        }
        .onDisappear {
            scrollAnimator.stop()
        }
    }
    
    var valueText: some View {
        if let formatter = formatter {
            return Text(formatterSubjectProvider!(value), formatter: formatter)
        } else {
            return Text("\(value)")
        }
    }
    
    func stepper() -> some View {
        Stepper(value: $value, label: { EmptyView() }, onEditingChanged: { started in
            withAnimation {
                state = (started ? .stepping : .idle)
            }
        })
            .opacity(state == .dragging || state == .scrolling ? 0.0 : 1.0)
            .labelsHidden()
            .padding(Params.stepperPadding)
    }
    
    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { dragValue in
                
                if (state == .idle || state == .scrolling) {
                    scrollAnimator.stop()
                    withAnimation {
                        state = .dragging
                        dragBaseValue = value
                    }
                }
                
                if state == .dragging {
                    value = dragBaseValue + deltaValueForDisplacement(dragValue.translation.width)
                }
                
            }
            .onEnded { dragValue in
                
                guard state == .dragging else { return }
                    
                let initialSpeed = dragValue.scrollInitialSpeedX(decelerationRate: scrollAnimationUtil.decelerationRate)
                if abs(initialSpeed) < Params.scrollMinInitialSpeed {
                    // NOTE: Not setting the value matching drag last translation because
                    // it becomes very hard to stick to certain desired value since during
                    // relasing finger some undesired drag happens nearly unavoidably
                    withAnimation {
                        state = .idle
                    }
                    return
                }
                
                value = dragBaseValue + deltaValueForDisplacement(dragValue.translation.width)
                
                scrollAnimationUtil.initialValue = value
                scrollAnimationUtil.initialSpeed = initialSpeed
                
                withAnimation {
                    state = .scrolling
                }
                scrollAnimator.start(duration: scrollAnimationUtil.duration)
                
            }
    }
    
    private func deltaValueForDisplacement(_ displacement: CGFloat) -> Double {
        -displacement / Params.rulerUnitSize
    }
    
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
        FloatField(value: .constant(0.0))
            .padding(8.0)
    }
}
