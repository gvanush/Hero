//
//  FloatField.swift
//  Hero
//
//  Created by Vanush Grigoryan on 29.10.21.
//

import SwiftUI

struct FloatField: View {
    
    enum Scale: Double, CaseIterable, Identifiable {
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
        
        var maximumFractionDigits: Int {
            switch self {
            case ._0_1:
                return 2
            case ._1:
                return 1
            case ._10:
                return 0
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
    
    @State private var formatter: Formatter
    
    typealias FormatterSubjectProvider = (Double) -> NSObject
    private let formatterSubjectProvider: FormatterSubjectProvider?
    
    @State var feedbackGenerator = UISelectionFeedbackGenerator()
        
    init(value: Binding<Double>, scale: Binding<Scale>) {
        _value = value
        _scale = scale
        self.formatter = NumberFormatter()
        self.formatterSubjectProvider = nil
        
        numberFormatter.roundingMode = .floor
        numberFormatter.maximumFractionDigits = self.scale.maximumFractionDigits
    }
    
    init(value: Binding<Double>, scale: Binding<Scale>, measurementFormatter: MeasurementFormatter, formatterSubjectProvider: @escaping FormatterSubjectProvider) {
        _value = value
        _scale = scale
        self.formatter = measurementFormatter
        self.formatterSubjectProvider = formatterSubjectProvider
        
        numberFormatter.roundingMode = .floor
        numberFormatter.maximumFractionDigits = self.scale.maximumFractionDigits
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ZStack(alignment: .top) {
                Ruler(unitSize: Self.rulerUnitSize, additionalUnitsCount: Self.rulerAdditionalUnitCount)
                    .offset(x: rulerOffsetX, y: 0.0)
                    .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black, .black.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
                    .padding(.horizontal, Self.padding)
                ZStack {
                    HStack {
                        ScalePicker(scale: $scale)
                            .opacity(state == .dragging || state == .scrolling ? 0.0 : 1.0)
                            
                        Spacer()
                    }
                    valueView
                }
                .padding(Self.padding)
                pointer
            }
            .contentShape(Rectangle())
            .gesture(dragGesture())
        }
        .frame(maxWidth: .infinity, idealHeight: Self.height)
        .fixedSize(horizontal: false, vertical: true)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .overlay(RoundedRectangle(cornerRadius: Self.cornerRadius).stroke(Color.orange, lineWidth: 1.0))
        .onAppear {
            scrollAnimator = DisplayRefreshSync(update: { time in
                assert(state == .scrolling)
                updateValue(dragBaseValue + deltaValue(translation: scrollAnimationUtil.value(at: time)))
            }, completion: {
                assert(state == .scrolling)
                withAnimation {
                    state = .idle
                }
            })
            feedbackGenerator.prepare()
        }
        .onDisappear {
            stopScrolling()
        }
        .onChange(of: scale) { _ in
            stopScrolling()
            updateFormatter(maximumFractionDigits: scale.maximumFractionDigits)
            // NOTE: This is needed because updating formatter does not trigger value text refresh
            updateValue(value.nextUp)
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
    }
    
    var valueView: some View {
        let valueText = { () -> Text in
            if formatter is MeasurementFormatter {
                return Text(formatterSubjectProvider!(value), formatter: formatter)
            } else {
                return Text(NSNumber(value: value), formatter: formatter)
            }
        }
        
        return HStack {
            Spacer()
            valueText()
                .foregroundColor(.secondary)
            Spacer()
        }
    }
    
    var pointer: some View {
        VStack {
            Spacer()
            Color.secondary
                .frame(width: Self.pointerWidth, height: Ruler.onesHeight * 2)
                .shadow(radius: 1.0)
        }
    }
    
    func dragGesture() -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { dragValue in
                
                if state == .scrolling {
                    scrollAnimator.stop()
                    withAnimation {
                        state = .idle
                    }
                }
                
                // NOTE: Typically the first non-zero drag translation is big which results to
                // aggresive jerk on the start, hence first non-zero translation is ignored
                if state == .idle && dragValue.translation.width != 0.0 {
                    withAnimation {
                        state = .dragging
                        dragBaseValue = value
                    }
                    dragInitialTranslation = dragValue.translation.width
                    return
                }
                
                if state == .dragging {
                    updateValue(dragBaseValue + deltaValue(translation: dragValue.translation.width - dragInitialTranslation))
                }
                
            }
            .onEnded { dragValue in
                
                guard state == .dragging else { return }
                    
                let initialSpeed = dragValue.scrollInitialSpeedX(decelerationRate: scrollAnimationUtil.decelerationRate)
                if abs(initialSpeed) < Self.scrollMinInitialSpeed {
                    // NOTE: Not setting the value matching drag last translation because
                    // it becomes very hard to stick to certain desired value since during
                    // relasing finger some undesired drag happens nearly unavoidably
                    withAnimation {
                        state = .idle
                    }
                    return
                }
                
                let translation = dragValue.translation.width - dragInitialTranslation
                updateValue(dragBaseValue + deltaValue(translation: translation))
                
                scrollAnimationUtil.initialValue = translation
                // NOTE: This speed factor is tweaked such that a soft scrolling results
                // to around 25 units of change while a hard one around 100
                scrollAnimationUtil.initialSpeed = 2.8 * initialSpeed
                
                withAnimation {
                    state = .scrolling
                }
                scrollAnimator.start(duration: scrollAnimationUtil.duration)
                
            }
    }
    
    private func updateValue(_ newValue: Double) {
        if newValue > value {
            updateFormatter(roundingMode: .floor)
        } else if newValue < value {
            updateFormatter(roundingMode: .ceiling)
        }
        value = newValue
    }
    
    private func updateFormatter(roundingMode: NumberFormatter.RoundingMode? = nil, maximumFractionDigits: Int? = nil) {
        let numberFormatter = numberFormatter
        let roundingMode = roundingMode ?? numberFormatter.roundingMode
        let maximumFractionDigits = maximumFractionDigits ?? numberFormatter.maximumFractionDigits
        
        if let measurementFormatter = formatter as? MeasurementFormatter {
            // NOTE: This is needed because measurement formatter is buggy in a sense that
            // changing underlying number formatter directly does not have any effect
            // after first formatting is requested, therefore new one is supllied
            let newNumberFormatter = NumberFormatter()
            newNumberFormatter.roundingMode = roundingMode
            newNumberFormatter.maximumFractionDigits = maximumFractionDigits
            measurementFormatter.numberFormatter = newNumberFormatter
        } else {
            numberFormatter.roundingMode = roundingMode
            numberFormatter.maximumFractionDigits = maximumFractionDigits
        }
    }
    
    private var numberFormatter: NumberFormatter {
        if let measurementFormatter = formatter as? MeasurementFormatter {
            return measurementFormatter.numberFormatter
        } else {
            return formatter as! NumberFormatter
        }
    }
    
    private func deltaValue(translation: CGFloat) -> Double {
        -scale.rawValue * (translation / Self.rulerUnitSize)
    }
    
    private var rulerOffsetX: CGFloat {
        -fmod(value / scale.rawValue, Double(Self.rulerAdditionalUnitCount)) * Self.rulerUnitSize
    }
    
    private func stopScrolling() {
        withAnimation {
            scrollAnimator.stop()
            state = .idle
        }
    }
    
    static let height = 75.0
    static let padding = 4.0
    static let cornerRadius = 11.0
    static let rulerUnitSize = 20.0
    static let rulerAdditionalUnitCount = 10
    static let pointerWidth = 1.0
    static let pointerHeight = 32.0
    static let scrollMinInitialSpeed = 100.0
    
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
                
                let subUnitSize = 0.1 * unitSize
                var baseX = 0.0
                let halfWidth = CGFloat(additionalUnitsCount) * unitSize + 0.5 * geometry.size.width
                while baseX <= halfWidth {
                    number += 1
                    baseX = Double(number) * subUnitSize
                    
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
        if number % 10 == 0 { return Self.onesHeight }
        if number % 5 == 0 { return Self.oneFifthsHeight }
        return Self.oneTenthsHeight
    }
    
    static let oneTenthsHeight = 2.0
    static let oneFifthsHeight = 4.0
    static let onesHeight = 16.0
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
        .background(Color.systemFill.cornerRadius(Self.cornerRadius).shadow(radius: Self.shadowRadius))
        .accentColor(.primary)
        .pickerStyle(.menu)
    }
    
    static let widrh = 50.0
    static let height = 29.0
    static let cornerRadius = 7.0
    static let shadowRadius = 1.0
}

struct FloatField_Previews: PreviewProvider {
    static var previews: some View {
        FloatField(value: .constant(0.0), scale: .constant(._1))
            .padding(8.0)
    }
}
