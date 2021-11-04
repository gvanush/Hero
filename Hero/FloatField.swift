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
    
    enum Scale: Double, CaseIterable, Identifiable {
        case x0_1 = 0.1
        case x1 = 1.0
        case x10 = 10.0
        
        var id: Self { self }
        
        var displayText: String {
            switch self {
            case .x0_1:
                return "0.1x"
            case .x1:
                return "1x"
            case .x10:
                return "10x"
            }
        }
    }
    
    private enum EditingState {
        case idle
        case dragging
        case scrolling
        case stepping
    }
    
    @Binding var value: Double
    @Binding var scale: Scale
    @State private var state = EditingState.idle
    
    @State private var dragBaseValue = 0.0
    @State private var dragInitialTranslation = 0.0
    
    @State private var scrollAnimator: DisplayRefreshSync!
    @State private var scrollAnimationUtil = ScrollAnimationUtil()
    
    private let formatter: Formatter?
    typealias FormatterSubjectProvider = (Double) -> NSObject
    private let formatterSubjectProvider: FormatterSubjectProvider?
        
    init(value: Binding<Double>, scale: Binding<Scale>) {
        _value = value
        _scale = scale
        self.formatter = nil
        self.formatterSubjectProvider = nil
    }
    
    init(value: Binding<Double>, scale: Binding<Scale>, formatter: Formatter, formatterSubjectProvider: @escaping FormatterSubjectProvider) {
        _value = value
        _scale = scale
        self.formatter = formatter
        self.formatterSubjectProvider = formatterSubjectProvider
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                valueView
                HStack(alignment: .top) {
                    ScalePicker(scale: $scale)
                    Spacer()
                    stepper
                }
                .padding(Params.stepperPadding)
            }
            ZStack {
                Color.secondary
                    .frame(idealWidth: Params.pointerWidth, maxHeight: .infinity)
                    .fixedSize(horizontal: true, vertical: false)
                Ruler(unitSize: Params.rulerUnitSize, additionalUnitsCount: Params.rulerAdditionalUnitCount)
                    .offset(x: rulerOffsetX, y: 0.0)
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
                assert(state == .scrolling)
                value = dragBaseValue + deltaValue(translation: scrollAnimationUtil.value(at: time))
            }, completion: {
                assert(state == .scrolling)
                withAnimation {
                    state = .idle
                }
            })
        }
        .onDisappear {
            scrollAnimator.stop()
        }
    }
    
    var valueView: some View {
        let valueText = { () -> Text in
            if let formatter = formatter {
                return Text(formatterSubjectProvider!(value), formatter: formatter)
            } else {
                return Text("\(value)")
            }
        }
        
        return HStack {
            Spacer()
            valueText()
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    var stepper: some View {
        Stepper(value: $value, label: { EmptyView() }, onEditingChanged: { started in
            withAnimation {
                state = (started ? .stepping : .idle)
            }
        })
            .opacity(state == .dragging || state == .scrolling ? 0.0 : 1.0)
            .labelsHidden()
    }
    
    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { dragValue in
                
                // NOTE: Typically the first non-zero drag translation is big which results to
                // aggresive jerk on the start, hence first non-zero translation is ignored
                if ((state == .idle || state == .scrolling) && dragValue.translation.width != 0.0) {
                    scrollAnimator.stop()
                    withAnimation {
                        state = .dragging
                        dragBaseValue = value
                    }
                    dragInitialTranslation = dragValue.translation.width
                    return
                }
                
                if state == .dragging {
                    value = dragBaseValue + deltaValue(translation: dragValue.translation.width - dragInitialTranslation)
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
                
                let translation = dragValue.translation.width - dragInitialTranslation
                value = dragBaseValue + deltaValue(translation: translation)
                
                scrollAnimationUtil.initialValue = translation
                scrollAnimationUtil.initialSpeed = initialSpeed
                
                withAnimation {
                    state = .scrolling
                }
                scrollAnimator.start(duration: scrollAnimationUtil.duration)
                
            }
    }
    
    private func deltaValue(translation: CGFloat) -> Double {
        -scale.rawValue * (translation / Params.rulerUnitSize)
    }
    
    private var rulerOffsetX: CGFloat {
        -fmod(value / scale.rawValue, Double(Params.rulerAdditionalUnitCount)) * Params.rulerUnitSize
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

fileprivate struct ScalePicker: View {
    @Binding var scale: FloatField.Scale
    
    var body: some View {
        Picker("", selection: $scale) {
            ForEach(FloatField.Scale.allCases) { scale in
                Text(scale.displayText)
            }
        }
        .frame(width: Self.widrh, height: Self.height, alignment: .center)
        .background(Color.systemFill)
        .cornerRadius(Self.cornerRadius)
        .accentColor(.primary)
        .pickerStyle(.menu)
    }
    
    static let widrh = 50.0
    static let height = 29.0
    static let cornerRadius = 7.0
}

struct FloatField_Previews: PreviewProvider {
    static var previews: some View {
        FloatField(value: .constant(0.0), scale: .constant(.x1))
            .padding(8.0)
    }
}
