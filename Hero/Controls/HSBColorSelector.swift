//
//  HSBColorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.11.22.
//

import SwiftUI

fileprivate extension SPTHSBAColor {
    
    func hued(_ hue: Float) -> SPTHSBAColor {
        var color = self
        color.hue = hue
        return color
    }
    
    func saturated(_ saturation: Float) -> SPTHSBAColor {
        var color = self
        color.saturation = saturation
        return color
    }
    
    func brighted(_ brightness: Float) -> SPTHSBAColor {
        var color = self
        color.brightness = brightness
        return color
    }
    
}

fileprivate let gradientColorSpace = Gradient.ColorSpace.device

struct HSBColorSelector: View {
    
    @Binding var hsbaColor: SPTHSBAColor
    let channel: HSBColorChannel
    let onStateChange: (Bool) -> Void
    
    init(hsbaColor: Binding<SPTHSBAColor>, channel: HSBColorChannel, onStateChange: @escaping (Bool) -> Void = { _ in }) {
        _hsbaColor = hsbaColor
        self.channel = channel
        self.onStateChange = onStateChange
    }
    
    @State private var prevLocation: CGPoint?
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack(spacing: 12.0) {
            HuePlaneView(hue: hsbaColor.hue)
                .aspectRatio(contentMode: .fit)
                .compositingGroup()
                .shadow(radius: 1.0)
                .overlay {
                    GeometryReader { geometry in
                        ZStack {
                            Color.clear
                            Group {
                                Circle()
                                    .fill(Color.white)
                                    .shadow(radius: 1.0)
                                    .foregroundColor(.white)
                                Circle()
                                    .fill(dotColor)
                                    .shadow(radius: 1.0)
                                    .padding(1.0)
                            }
                            .frame(width: 11.0, height: 11.0)
                            .offset(dotOffset(geometry: geometry))
                        }
                    }
                }
            Divider()
            VStack {
                Text(NSNumber(value: channelValue), formatter: Formatters.colorChannel)
                    .font(.body.monospacedDigit())
                    .foregroundColor(.controlValue)
                GeometryReader { geometry in
                    ZStack {
                        track()
                        thumb(geometry: geometry)
                    }
                    .contentShape(Rectangle())
                    .gesture(dragGesture(geometry: geometry))
                }
                .background(alignment: .bottom) {
                    dragIndicator()
                }
                .background(alignment: .top) {
                    dragIndicator()
                }
            }
            .padding(.trailing, 4.0)
        }
        .padding(Self.padding)
        .frame(maxWidth: .infinity, maxHeight: Self.maxHeight)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
        .onAppear {
            feedbackGenerator.prepare()
        }
        .onDisappear {
            if isEditing {
                onStateChange(false)
            }
        }
        .onChange(of: isEditing) { newValue in
            onStateChange(isEditing)
        }
    }
    
    var isEditing: Bool {
        prevLocation != nil
    }
    
    var channelValue: Float {
        hsbaColor.float4[channel.rawValue]
    }
    
    func thumb(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 3.0)
            .fill(thumbColor)
            .frame(width: 8.0)
            .shadow(radius: 1.0)
            .offset(x: thumbOffset(geometry: geometry))
    }
    
    func track() -> some View {
        Group {
            switch channel {
            case .hue:
                Capsule()
                    .fill(.linearGradient(hueTrackGradient, startPoint: .leading, endPoint: .trailing))
            case .saturation:
                Capsule()
                    .fill(.linearGradient(saturationTrackGradient, startPoint: .leading, endPoint: .trailing))
            case .brightness:
                Capsule()
                    .fill(.linearGradient(brightnessTrackGradient, startPoint: .leading, endPoint: .trailing))
            }
        }
        .frame(height: 4.0)
    }
    
    var hueTrackGradient: AnyGradient {
        Gradient(colors: Self.spectrumColors).colorSpace(gradientColorSpace)
    }
    
    var saturationTrackGradient: AnyGradient {
        Gradient(colors: [.init(sptHSBA: hsbaColor.saturated(0.0)), .init(sptHSBA: hsbaColor.saturated(1.0))])
            .colorSpace(gradientColorSpace)
    }
    
    var brightnessTrackGradient: AnyGradient {
        Gradient(colors: [.init(sptHSBA: hsbaColor.brighted(0.0)), .init(sptHSBA: hsbaColor.brighted(1.0))])
            .colorSpace(gradientColorSpace)
    }
    
    var thumbColor: Color {
        switch channel {
        case .hue:
            return Color(hue: Double(hsbaColor.hue), saturation: 1.0, brightness: 1.0)
        case .saturation, .brightness:
            return dotColor
        }
    }
    
    func thumbOffset(geometry: GeometryProxy) -> CGFloat {
        CGFloat(2.0 * channelValue - 1.0) * geometry.size.width * 0.5
    }
    
    func dotOffset(geometry: GeometryProxy) -> CGSize {
        .init(width: CGFloat(2.0 * hsbaColor.saturation - 1.0) * geometry.size.width * 0.5,
              height: CGFloat(1.0 - 2.0 * hsbaColor.brightness) * geometry.size.height * 0.5)
    }
    
    var dotColor: Color {
        Color(sptHSBA: hsbaColor)
    }
    
    func dragGesture(geometry: GeometryProxy) -> some Gesture {
        
        DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                guard let prevLocation = prevLocation else {
                    // NOTE: Typically the first non-zero drag translation is big which results to
                    // aggresive jerk on the start, hence first non-zero translation is ignored
                    if value.translation.width != 0.0 {
                        prevLocation = value.location
                    }
                    return
                }
                let delta = value.location.x - prevLocation.x
                let newValue = simd_clamp(channelValue + Float(delta / geometry.size.width), 0.0, 1.0)
                if (channelValue != 0.0 && newValue == 0.0) || (channelValue != 1.0 && newValue == 1.0) {
                    feedbackGenerator.impactOccurred()
                }
                
                hsbaColor.float4[channel.rawValue] = newValue
                self.prevLocation = value.location
            }
            .onEnded { _ in
                prevLocation = nil
            }
    }
    
    func dragIndicator() -> some View {
        HLine()
            .stroke(style: StrokeStyle(lineWidth: 4.0, dash: [1, 4]))
            .foregroundColor(.primarySelectionColor)
            .frame(height: 4.0)
            .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
    }
    
    static let spectrumColors: [Color] = [
        .init(red: 1.0, green: 0.0, blue: 0.0),
        .init(red: 1.0, green: 1.0, blue: 0.0),
        .init(red: 0.0, green: 1.0, blue: 0.0),
        .init(red: 0.0, green: 1.0, blue: 1.0),
        .init(red: 0.0, green: 0.0, blue: 1.0),
        .init(red: 1.0, green: 0.0, blue: 1.0),
        .init(red: 1.0, green: 0.0, blue: 0.0),
    ]
    static let padding = 8.0
    static let cornerRadius = 11.0
    static let maxHeight = 75.0
}

struct HuePlaneView: View {
    
    let hue: Float
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                ForEach(0...Int(geometry.size.width), id: \.self) { i in
                    VLine()
                        .stroke(.linearGradient(Gradient(colors: [.black, .init(hue: Double(hue), saturation: Double(i) / geometry.size.width, brightness: 1.0)]).colorSpace(gradientColorSpace), startPoint: .bottom, endPoint: .top))
                        .frame(width: 1.0)
                }
            }
        }
    }
    
}

struct HSVColorSelector_Previews: PreviewProvider {
    
    struct ContanerView: View {
        
        @State var color = SPTHSBAColor(hue: 1.0, saturation: 1.0, brightness: 1.0)
        
        var body: some View {
            VStack {
                HSBColorSelector(hsbaColor: $color, channel: .hue)
                    .tint(.primarySelectionColor)
                
                HSBColorSelector(hsbaColor: $color, channel: .saturation)
                    .tint(.primarySelectionColor)
                
                HSBColorSelector(hsbaColor: $color, channel: .brightness)
                    .tint(.primarySelectionColor)
            }
            .environmentObject(UserInteractionState())
        }
    }
    
    static var previews: some View {
        ContanerView()
            .padding()
    }
}
