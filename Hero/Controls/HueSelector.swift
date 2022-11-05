//
//  HSVColorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.11.22.
//

import SwiftUI

enum HSBAColorComponent: Int {
    case hue
    case saturation
    case brightness
    case alpha
}

typealias HSBAColor = simd_float4

extension HSBAColor {
    
    func hued(_ hue: Float) -> HSBAColor {
        var color = self
        color.x = hue
        return color
    }
    
    func saturated(_ saturation: Float) -> HSBAColor {
        var color = self
        color.y = saturation
        return color
    }
    
    func brighted(_ brightness: Float) -> HSBAColor {
        var color = self
        color.z = brightness
        return color
    }
    
}

fileprivate let gradientColorSpace = Gradient.ColorSpace.device

struct HSVColorSelector: View {
    
    @Binding var hsbaColor: HSBAColor
    let component: HSBAColorComponent
    
    @State private var prevLocation: CGPoint?
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack(spacing: Self.padding) {
            HuePlaneView(hue: hsbaColor.x)
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
            VStack {
                Text(String(format: "%.2f", componentValue))
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
            .padding(.horizontal, 8.0)
        }
        .padding(Self.padding)
        .frame(maxWidth: .infinity, maxHeight: Self.maxHeight)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
    }
    
    var componentValue: Float {
        hsbaColor[component.rawValue]
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
            switch component {
            case .hue:
                Capsule()
                    .fill(.linearGradient(hueTrackGradient, startPoint: .leading, endPoint: .trailing))
            case .saturation:
                Capsule()
                    .fill(.linearGradient(saturationTrackGradient, startPoint: .leading, endPoint: .trailing))
            case .brightness:
                Capsule()
                    .fill(.linearGradient(brightnessTrackGradient, startPoint: .leading, endPoint: .trailing))
            case .alpha:
                EmptyView()
            }
        }
        .frame(height: 4.0)
    }
    
    var hueTrackGradient: AnyGradient {
        Gradient(colors: Self.spectrumColors).colorSpace(gradientColorSpace)
    }
    
    var saturationTrackGradient: AnyGradient {
        Gradient(colors: [.init(hsba: hsbaColor.saturated(0.0)), .init(hsba: hsbaColor.saturated(1.0))])
            .colorSpace(gradientColorSpace)
    }
    
    var brightnessTrackGradient: AnyGradient {
        Gradient(colors: [.init(hsba: hsbaColor.brighted(0.0)), .init(hsba: hsbaColor.brighted(1.0))])
            .colorSpace(gradientColorSpace)
    }
    
    var thumbColor: Color {
        switch component {
        case .hue:
            return Color(hue: Double(hsbaColor.x), saturation: 1.0, brightness: 1.0)
        case .saturation, .brightness:
            return dotColor
        case .alpha:
            return Color.black
        }
    }
    
    func thumbOffset(geometry: GeometryProxy) -> CGFloat {
        CGFloat(2.0 * componentValue - 1.0) * geometry.size.width * 0.5
    }
    
    func dotOffset(geometry: GeometryProxy) -> CGSize {
        .init(width: CGFloat(2.0 * hsbaColor.y - 1.0) * geometry.size.width * 0.5,
              height: CGFloat(1.0 - 2.0 * hsbaColor.z) * geometry.size.height * 0.5)
    }
    
    var dotColor: Color {
        Color(hsba: hsbaColor)
    }
    
    func dragGesture(geometry: GeometryProxy) -> some Gesture {
        
        DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                guard let prevLocation = prevLocation else {
                    prevLocation = value.location
                    return
                }
                let delta = value.location.x - prevLocation.x
                let newValue = simd_clamp(componentValue + Float(delta / geometry.size.width), 0.0, 1.0)
                if (componentValue != 0.0 && newValue == 0.0) || (componentValue != 1.0 && newValue == 1.0) {
                    feedbackGenerator.impactOccurred()
                }
                
                hsbaColor[component.rawValue] = newValue
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
        
        @State var color = HSBAColor(x: 1.0, y: 1.0, z: 1.0, w: 1.0)
        
        var body: some View {
            VStack {
                HSVColorSelector(hsbaColor: $color, component: .hue)
                    .tint(.primarySelectionColor)
                
                HSVColorSelector(hsbaColor: $color, component: .saturation)
                    .tint(.primarySelectionColor)
                
                HSVColorSelector(hsbaColor: $color, component: .brightness)
                    .tint(.primarySelectionColor)
            }
        }
    }
    
    static var previews: some View {
        ContanerView()
            .padding()
    }
}
