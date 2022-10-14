//
//  FloatSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.10.21.
//

import SwiftUI

struct FloatSelector: View {
    
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
    
    private enum EditingState {
        case idle
        case dragging
        case scrolling
        case snapping
    }
    
    @Binding var value: Float
    @Binding var scale: Scale
    @Binding var isSnappingEnabled: Bool
    @State private var state = EditingState.idle
    
    @State private var dragBaseValue: Float = 0.0
    @State private var dragInitialTranslation: CGFloat = 0.0
    
    @State private var scrollAnimationUtil = ScrollAnimationUtil()
    @State private var scrollDuration: TimeInterval = 0.0
    @State private var scrollStartTimestamp: TimeInterval = 0.0
    @State private var snapInitialValue: Float = 0.0
    @State private var snapDeltaValue: Float = 0.0
    
    @State private var formatter: Formatter
    
    typealias FormatterSubjectProvider = (Float) -> NSObject
    private var formatterSubjectProvider: FormatterSubjectProvider?
    
    @State private var feedbackGenerator = UISelectionFeedbackGenerator()
    
    @State private var rawValue: Float {
        willSet {
            if isSnappingEnabled {
                value = roundedValue(newValue)
            } else {
                value = newValue
            }
        }
    }
        
    init(value: Binding<Float>, scale: Binding<Scale>, isSnappingEnabled: Binding<Bool>) {
        _value = value
        _scale = scale
        _isSnappingEnabled = isSnappingEnabled
        self.rawValue = value.wrappedValue
        self.formatter = Self.defaultNumberFormatter(scale: scale.wrappedValue)
        self.formatterSubjectProvider = nil
    }
    
    init(value: Binding<Float>, scale: Binding<Scale>, isSnappingEnabled: Binding<Bool>, measurementFormatter: MeasurementFormatter, formatterSubjectProvider: @escaping FormatterSubjectProvider) {
        _value = value
        _scale = scale
        _isSnappingEnabled = isSnappingEnabled
        self.rawValue = value.wrappedValue
        self.formatter = measurementFormatter
        self.formatterSubjectProvider = formatterSubjectProvider
        
        numberFormatter.roundingMode = .halfEven
        numberFormatter.maximumFractionDigits = self.scale.fractionDigits
        numberFormatter.minimumFractionDigits = self.scale.fractionDigits
        
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Ruler(unitSize: Self.rulerUnitSize, additionalUnitsCount: Self.rulerAdditionalUnitCount, integerNumbers: isSnappingEnabled)
                    .offset(x: rulerOffsetX, y: 0.0)
                    .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black, .black.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                    .padding(.horizontal, Self.padding)
                    .animation(nil, value: rawValue)
                ZStack {
                    HStack {
                        ScalePicker(scale: $scale)
                        Spacer()
                        SnappingToggle(isOn: $isSnappingEnabled)
                    }
                    .visible(!(state == .dragging || state == .scrolling))
                    valueView
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
        .onChange(of: scale) { _ in
            stopScrolling()
            updateFormatter(fractionDigits: scale.fractionDigits)
            // NOTE: This is needed because updating formatter does not trigger value text refresh
            rawValue = rawValue.nextUp
        }
        .onChange(of: isSnappingEnabled) { newValue in
            stopScrolling()
            if newValue {
                updateFormatter(fractionDigits: scale.snappedFractionDigits)
                startSnapping()
            } else {
                updateFormatter(fractionDigits: scale.fractionDigits)
            }
        }
        .onChange(of: value) { [value] newValue in
            guard state == .dragging || state == .scrolling else { return }
            
            let playFeedback = {
                feedbackGenerator.selectionChanged()
                feedbackGenerator.prepare()
            }
            
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
                
            case .dragging:
                break
            case .idle:
                break
            }
            
        }
    }
    
    var valueView: some View {
        let valueText = { () -> Text in
            // This is to eliminate minus zero being displayed (no option found in formatter API)
            let value = (value == 0.0 ? 0.0 : value)
            return formatter is MeasurementFormatter ? Text(formatterSubjectProvider!(value), formatter: formatter) : Text(NSNumber(value: value), formatter: formatter)
        }
        
        return HStack {
            Spacer()
            valueText()
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
                    stopScrolling()
                }
                
                // NOTE: Typically the first non-zero drag translation is big which results to
                // aggresive jerk on the start, hence first non-zero translation is ignored
                if state == .idle && dragValue.translation.width != 0.0 {
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
    
    private func updateFormatter(fractionDigits: Int) {
        let numberFormatter = numberFormatter
        
        if let measurementFormatter = formatter as? MeasurementFormatter {
            // NOTE: This is needed because measurement formatter is buggy in a sense that
            // changing underlying number formatter directly does not have any effect
            // after first formatting is requested, therefore new one is supllied
            let newNumberFormatter = NumberFormatter()
            newNumberFormatter.minimumFractionDigits = fractionDigits
            newNumberFormatter.maximumFractionDigits = fractionDigits
            measurementFormatter.numberFormatter = newNumberFormatter
        } else {
            numberFormatter.minimumFractionDigits = fractionDigits
            numberFormatter.maximumFractionDigits = fractionDigits
        }
    }
    
    private var numberFormatter: NumberFormatter {
        if let measurementFormatter = formatter as? MeasurementFormatter {
            return measurementFormatter.numberFormatter
        } else {
            return formatter as! NumberFormatter
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
    
    private func stopScrolling() {
        withAnimation {
            state = .idle
        }
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
    
    static func defaultNumberFormatter(scale: Scale) -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.roundingMode = .halfEven
        formatter.maximumFractionDigits = scale.fractionDigits
        formatter.minimumFractionDigits = scale.fractionDigits
        return formatter
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
            .stroke(lineWidth: 1.0)
            .foregroundColor(Color.objectSelectionColor)
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
