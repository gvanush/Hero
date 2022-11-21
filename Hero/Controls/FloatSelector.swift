//
//  FloatSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.10.21.
//

import SwiftUI


struct FloatSelector: View {
    
    struct ValueTransformer {
        
        let transform: (Float) -> Float
        let inverse: (Float) -> Float
        
        static let identity = ValueTransformer(transform: { $0 }, inverse: { $0 })
        static let frequency = ValueTransformer { value in
            if value >= 0.0 {
                return value + 1.0
            } else {
                return 1.0 / (1.0 - value)
            }
        } inverse: { freq in
            if freq >= 1.0 {
                return freq - 1.0
            } else {
                return 1.0 - 1.0 / freq
            }
        }

    }
    
    enum Scale: Float, CaseIterable, Identifiable {
        case _0_1 = 0.1
        case _1 = 1.0
        case _10 = 10.0
        
        var id: Self { self }
        
        var displayText: String {
            switch self {
            case ._0_1:
                return "1 : 0.1"
            case ._1:
                return "1 : 1"
            case ._10:
                return "1 : 10"
            }
        }
        
        var fractionDigits: Int {
            switch self {
            case ._0_1:
                return 3
            case ._1:
                return 2
            case ._10:
                return 1
            }
        }
        
        var snappedFractionDigits: Int {
            max(0, self.fractionDigits - 2)
        }
        
    }
    
    enum EditingState {
        case idle
        case dragging
        case scrolling
        case holding // State right after manually stopping scrolling but not yet dragging
        case snapping
    }
    
    @Binding var value: Float
    let valueTransformer: ValueTransformer
    @Binding var scale: Scale
    @Binding var isSnappingEnabled: Bool
    @State private var state = EditingState.idle
    let onStateChange: (EditingState) -> Void
    
    @State private var dragBaseValue: Float = 0.0
    @State private var dragInitialTranslation: CGFloat = 0.0
    
    @State private var scrollAnimationUtil = ScrollAnimationUtil()
    @State private var scrollDuration: TimeInterval = 0.0
    @State private var scrollStartTimestamp: TimeInterval = 0.0
    @State private var snapInitialValue: Float = 0.0
    @State private var snapDeltaValue: Float = 0.0
    
    private let formatter: FloatFormatter
    
    @State private var feedbackGenerator = UISelectionFeedbackGenerator()
    
    @State private var rawValue: Float {
        willSet {
            value = valueTransformer.transform(isSnappingEnabled ? roundedValue(newValue) : newValue)
        }
    }
        
    init(value: Binding<Float>, valueTransformer: ValueTransformer = .identity, scale: Binding<Scale>, isSnappingEnabled: Binding<Bool>, formatter: FloatFormatter = BasicFloatFormatter(), onStateChange: @escaping (EditingState) -> Void = { _ in }) {
        _value = value
        self.valueTransformer = valueTransformer
        _scale = scale
        _isSnappingEnabled = isSnappingEnabled
        self.rawValue = valueTransformer.inverse(value.wrappedValue)
        self.formatter = formatter
        self.onStateChange = onStateChange
        
        self.formatter.updateFractionDigits(self.isSnappingEnabled ? self.scale.snappedFractionDigits : self.scale.fractionDigits)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Ruler(unitSize: Self.rulerUnitSize, additionalUnitsCount: Self.rulerAdditionalUnitCount, integerNumbers: isSnappingEnabled)
                    .offset(x: rulerOffsetX, y: 0.0)
                    .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black, .black, .black.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                    .padding(.horizontal, Self.padding)
                    .animation(nil, value: rawValue)
                ZStack {
                    HStack {
                        ScalePicker(scale: $scale)
                        Spacer()
                        SnappingToggle(isOn: $isSnappingEnabled)
                    }
                    .visible(state == .idle || state == .snapping)
                    valueView
                        .id(scale)
                        .id(isSnappingEnabled)
                }
                .padding(Self.padding)
                pointer
            }
            .contentShape(Rectangle())
            .gesture(dragGesture())
        }
        .frame(maxWidth: .infinity)
        .frame(height: Self.height)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
        .onAppear {
            feedbackGenerator.prepare()
        }
        .onDisappear {
            if state != .idle {
                onStateChange(.idle)
            }
        }
        .onChange(of: scale) { newScale in
            withAnimation {
                state = .idle
            }
            formatter.updateFractionDigits(isSnappingEnabled ? newScale.snappedFractionDigits : newScale.fractionDigits)
            if isSnappingEnabled {
                startSnapping()
            }
        }
        .onChange(of: isSnappingEnabled) { newValue in
            withAnimation {
                state = .idle
            }
            if newValue {
                startSnapping()
                formatter.updateFractionDigits(scale.snappedFractionDigits)
            } else {
                formatter.updateFractionDigits(scale.fractionDigits)
            }
        }
        .onChange(of: rawValue) { [rawValue] newRawValue in
            guard state == .dragging || state == .scrolling else { return }
            
            let playFeedback = {
                feedbackGenerator.selectionChanged()
                feedbackGenerator.prepare()
            }
            
            let value = isSnappingEnabled ? roundedValue(rawValue) : rawValue
            let newValue = isSnappingEnabled ? roundedValue(newRawValue) : newRawValue
            if newValue > value {
                if floor(value / scale.rawValue) != floor(newValue / scale.rawValue) {
                    playFeedback()
                }
            } else {
                if ceil(value / scale.rawValue) != ceil(newValue / scale.rawValue) {
                    playFeedback()
                }
            }
        }
        .onChange(of: state, perform: { newValue in
            onStateChange(newValue)
        })
        .onFrame { frame in
            
            switch state {
            case .scrolling:
                var passeedTime = frame.timestamp - scrollStartTimestamp
                if passeedTime >= scrollDuration {
                    passeedTime = scrollDuration
                    withAnimation {
                        state = .idle
                    }
                }
                rawValue = dragBaseValue + deltaValue(translation: scrollAnimationUtil.value(at: passeedTime))
                
            case .snapping:
                var passeedTime = frame.timestamp - scrollStartTimestamp
                if passeedTime >= scrollDuration {
                    passeedTime = scrollDuration
                    withAnimation {
                        state = .idle
                    }
                }
                rawValue = snapInitialValue + snapDeltaValue * Float((passeedTime / scrollDuration))
                
            case .idle, .dragging, .holding:
                break
            }
            
        }
    }
    
    var valueView: some View {
        HStack {
            Spacer()
            Text(NSNumber(value: value == 0.0 ? 0.0 : value), formatter: formatter)
                .font(.body.monospacedDigit())
                .foregroundColor(.controlValue)
            Spacer()
        }
    }
    
    var pointer: some View {
        VStack {
            Spacer()
            Color.controlValue
                .frame(width: Self.pointerWidth, height: Ruler.onesHeight * 2)
                .shadow(radius: 1.0)
        }
    }
    
    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { dragValue in
                
                if state == .scrolling || state == .snapping {
                    withAnimation {
                        state = .holding
                    }
                }
                
                // NOTE: Typically the first non-zero drag translation is big which results to
                // aggresive jerk on the start, hence first non-zero translation is ignored
                if (state == .idle || state == .holding) && dragValue.translation.width != 0.0 {
                    withAnimation {
                        state = .dragging
                        dragBaseValue = rawValue
                    }
                    dragInitialTranslation = dragValue.translation.width
                    return
                }
                
                if state == .dragging {
                    rawValue = dragBaseValue + deltaValue(translation: dragValue.translation.width - dragInitialTranslation)
                }
                
            }
            .onEnded { dragValue in
                
                if state == .holding {
                    withAnimation {
                        state = .idle
                    }
                    return
                }
                
                guard state == .dragging || state == .idle else { return }
                
                var initialSpeed = dragValue.scrollInitialSpeedX(decelerationRate: scrollAnimationUtil.decelerationRate) * Self.scrollInitialSpeedFactor
                if abs(initialSpeed) < Self.scrollMinInitialSpeed {
                    // NOTE: Not setting the value matching drag last translation because
                    // it becomes very hard to stick to certain desired value since during
                    // relasing finger some undesired drag happens nearly unavoidably
                    if isSnappingEnabled {
                        startSnapping()
                    } else {
                        withAnimation {
                            state = .idle
                        }
                    }
                    return
                }
                
                if isSnappingEnabled {
                    // Adjust 'initialSpeed' so that ruler stops at right location
                    var endTranslation = ScrollAnimationUtil.distance(initialSpeed: initialSpeed, decelerationRate: scrollAnimationUtil.decelerationRate)
                    let finalValue = roundedValue(dragBaseValue + deltaValue(translation: endTranslation - dragInitialTranslation))
                    endTranslation = translation(deltaValue: finalValue - dragBaseValue) + dragInitialTranslation
                    initialSpeed = ScrollAnimationUtil.initialSpeed(distance: endTranslation - dragValue.translation.width, decelerationRate: scrollAnimationUtil.decelerationRate)
                }
                
                let translation = dragValue.translation.width - dragInitialTranslation
                rawValue = dragBaseValue + deltaValue(translation: translation)
                
                scrollAnimationUtil.initialValue = translation
                scrollAnimationUtil.initialSpeed = initialSpeed
                
                scrollDuration = scrollAnimationUtil.duration
                scrollStartTimestamp = CACurrentMediaTime()
                withAnimation {
                    state = .scrolling
                }
                
            }
    }
    
    private func startSnapping() {
        snapInitialValue = rawValue
        snapDeltaValue = roundedValue(rawValue) - rawValue
        scrollDuration = 0.1
        scrollStartTimestamp = CACurrentMediaTime()
        withAnimation {
            state = .snapping
        }
    }
    
    private func deltaValue(translation: CGFloat) -> Float {
        -scale.rawValue * Float(translation / Self.rulerUnitSize)
    }
    
    private func translation(deltaValue: Float) -> CGFloat {
        -CGFloat(deltaValue / scale.rawValue) * Self.rulerUnitSize
    }
    
    private var rulerOffsetX: CGFloat {
        -fmod(CGFloat(rawValue / scale.rawValue), CGFloat(Self.rulerAdditionalUnitCount)) * Self.rulerUnitSize
    }
    
    private func roundedValue(_ value: Float) -> Float {
        switch scale {
        case ._0_1:
            return (value * 10.0).rounded() / 10.0
        case ._1:
            return value.rounded()
        case ._10:
            return (value / 10.0).rounded() * 10.0
        }
    }
    
    static let height = 75.0
    static let padding = 4.0
    static let cornerRadius = 11.0
    static let rulerUnitSize: CGFloat = 30.0
    static let rulerAdditionalUnitCount = 10
    static let pointerWidth = 1.0
    static let pointerHeight = 32.0
    
    // NOTE: This speed factor is tweaked such that a soft scrolling results
    // to around 25 units of change while a hard one around 100
    static let scrollInitialSpeedFactor = 2.8
    static let scrollMinInitialSpeed = 100.0 * scrollInitialSpeedFactor
}


fileprivate struct Ruler: View {
    
    let unitSize: CGFloat
    let additionalUnitsCount: Int
    let integerNumbers: Bool
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                var number = 0
                
                let midX = 0.5 * geometry.size.width
                
                path.move(to: CGPoint(x: midX, y: geometry.size.height))
                path.addLine(to: CGPoint(x: midX, y: geometry.size.height - heightFor(number)))
                
                let subUnitSize = 0.1 * unitSize
                var baseX: CGFloat = 0.0
                let halfWidth = CGFloat(additionalUnitsCount) * unitSize + 0.5 * geometry.size.width
                while baseX <= halfWidth {
                    number += (integerNumbers ? 10 : 1)
                    baseX = CGFloat(number) * subUnitSize
                    
                    let y = geometry.size.height - heightFor(number)
                    
                    for x in [midX + baseX, midX - baseX] {
                        path.move(to: CGPoint(x: x, y: geometry.size.height))
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                    
                }
            }
            .stroke(.tint, lineWidth: 1.0)
        }
    }
    
    func heightFor(_ number: Int) -> CGFloat {
        if number % 10 == 0 { return Self.onesHeight }
        if number % 5 == 0 { return Self.oneFifthsHeight }
        return Self.oneTenthsHeight
    }
    
    static let oneTenthsHeight = 3.0
    static let oneFifthsHeight = 6.0
    static let onesHeight = 16.0
}


fileprivate struct ScalePicker: View {
    @Binding var scale: FloatSelector.Scale
    
    var body: some View {
        Picker("", selection: $scale) {
            ForEach(FloatSelector.Scale.allCases) { scale in
                Text(scale.displayText)
            }
        }
        .tint(.secondaryLabel)
        .pickerStyle(.menu)
        .frame(height: Self.height, alignment: .center)
        .overlay {
            RoundedRectangle(cornerRadius: Self.cornerRadius)
                .strokeBorder(Color.tertiaryLabel, lineWidth: 1)
        }
    }
    
    static let height = 29.0
    static let cornerRadius = 7.0
}

struct SnappingToggle: View {
    
    @Binding var isOn: Bool
    
    var body: some View {
        Button {
            isOn.toggle()
        } label: {
            ZStack {
                RoundedRectangle(cornerRadius: 7.0)
                    .fill(.shadow(.inner(radius: 3.0)))
                    .foregroundColor(Color.systemFill)
                    .visible(isOn)
                Image(systemName: isOn ? "arrow.right.and.line.vertical.and.arrow.left" : "arrow.left.and.right")
            }
            .frame(width: Self.width, height: Self.height, alignment: .center)
            .overlay {
                RoundedRectangle(cornerRadius: Self.cornerRadius)
                    .strokeBorder(Color.tertiaryLabel, lineWidth: 1)
            }
        }
        .tint(.secondaryLabel)
    }
    
    static let width = 58.0
    static let height = 29.0
    static let cornerRadius = 7.0
    
}


struct FloatField_Previews: PreviewProvider {
    static var previews: some View {
        FloatSelector(value: .constant(0.0), scale: .constant(._1), isSnappingEnabled: .constant(false))
            .padding(8.0)
    }
}
