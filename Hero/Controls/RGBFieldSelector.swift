//
//  RGBColorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.11.22.
//

import SwiftUI
import simd


fileprivate extension SPTRGBAColor {
    
    func reded(_ red: Float) -> SPTRGBAColor {
        var color = self
        color.red = red
        return color
    }
    
    func greened(_ green: Float) -> SPTRGBAColor {
        var color = self
        color.green = green
        return color
    }
    
    func blued(_ blue: Float) -> SPTRGBAColor {
        var color = self
        color.blue = blue
        return color
    }
    
}

fileprivate let gradientColorSpace = Gradient.ColorSpace.device

struct RGBColorSelector: View {
    
    @Binding var rgbaColor: SPTRGBAColor
    let channel: RGBColorChannel
    
    @State private var prevLocation: CGPoint?
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack {
            HStack(spacing: 12.0) {
                HStack(spacing: 2.0) {
                    textForSecondaryChannel(secondaryComponent1)
                    trackForSecondaryChannel(secondaryComponent1)
                }
                HStack(spacing: 2.0) {
                    trackForSecondaryChannel(secondaryComponent2)
                    textForSecondaryChannel(secondaryComponent2)
                }
            }
            VStack {
                Text(String(format: "%.2f", channelValue))
                    .font(.body.monospacedDigit())
                    .foregroundColor(.controlValue)
                GeometryReader { geometry in
                    ZStack {
                        track
                        thumb(geometry: geometry)
                    }
                    .contentShape(Rectangle())
                    .gesture(dragGesture(geometry: geometry))
                    .background(alignment: .bottom) {
                        dragIndicator()
                    }
                    .background(alignment: .top) {
                        dragIndicator()
                    }
                }
            }
            .padding(.horizontal, 8.0)
        }
        .padding(Self.padding)
        .frame(maxWidth: .infinity, maxHeight: Self.maxHeight)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
        .onAppear {
            feedbackGenerator.prepare()
        }
    }
    
    var track: some View {
        Capsule()
            .fill(.linearGradient(trackGradient, startPoint: .leading, endPoint: .trailing))
            .frame(height: 4.0)
    }
    
    var trackGradient: AnyGradient {
        Gradient(colors: [startColorForChannel(channel), endColorForChannel(channel)])
            .colorSpace(gradientColorSpace)
    }
    
    func thumb(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 3.0)
            .fill(Color(sptRGBA: rgbaColor))
            .frame(width: 8.0)
            .shadow(radius: 1.0)
            .offset(x: thumbOffset(geometry: geometry))
    }
    
    func thumbOffset(geometry: GeometryProxy) -> CGFloat {
        CGFloat(2.0 * channelValue - 1.0) * geometry.size.width * 0.5
    }
    
    func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .onChanged { value in
                guard let prevLocation = prevLocation else {
                    prevLocation = value.location
                    return
                }
                let delta = value.location.x - prevLocation.x
                let newValue = simd_clamp(channelValue + Float(delta / geometry.size.width), 0.0, 1.0)
                if (channelValue != 0.0 && newValue == 0.0) || (channelValue != 1.0 && newValue == 1.0) {
                    feedbackGenerator.impactOccurred()
                }
                
                rgbaColor.float4[channel.rawValue] = newValue
                self.prevLocation = value.location
            }
            .onEnded { _ in
                prevLocation = nil
            }
    }
    
    var channelValue: Float {
        rgbaColor.float4[channel.rawValue]
    }
    
    func dragIndicator() -> some View {
        HLine()
            .stroke(style: StrokeStyle(lineWidth: 4.0, dash: [1, 4]))
            .foregroundColor(.primarySelectionColor)
            .frame(height: 4.0)
            .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
    }
    
    func textForSecondaryChannel(_ channel: RGBColorChannel) -> some View {
        Text(nameForSecondaryComponent(channel))
            .font(.caption.monospaced())
            .foregroundColor(.secondary)
    }
    
    func trackForSecondaryChannel(_ channel: RGBColorChannel) -> some View {
        Capsule()
            .fill(.linearGradient(colors: [startColorForChannel(channel), endColorForChannel(channel)], startPoint: .bottom, endPoint: .top))
            .frame(width: 4.0)
    }
    
    func nameForSecondaryComponent(_ channel: RGBColorChannel) -> String {
        switch channel {
        case .red:
            return "R"
        case .green:
            return "G"
        case .blue:
            return "B"
        }
    }
    
    var secondaryComponent1: RGBColorChannel {
        switch channel {
        case .red:
            return .green
        case .green:
            return .blue
        case .blue:
            return .red
        }
    }
    
    var secondaryComponent2: RGBColorChannel {
        switch channel {
        case .red:
            return .blue
        case .green:
            return .red
        case .blue:
            return .green
        }
    }
    
    func startColorForChannel(_ channel: RGBColorChannel) -> Color {
        switch channel {
        case .red:
            return .init(sptRGBA: rgbaColor.reded(0.0))
        case .green:
            return .init(sptRGBA: rgbaColor.greened(0.0))
        case .blue:
            return .init(sptRGBA: rgbaColor.blued(0.0))
        }
    }
    
    func endColorForChannel(_ channel: RGBColorChannel) -> Color {
        switch channel {
        case .red:
            return .init(sptRGBA: rgbaColor.reded(1.0))
        case .green:
            return .init(sptRGBA: rgbaColor.greened(1.0))
        case .blue:
            return .init(sptRGBA: rgbaColor.blued(1.0))
        }
    }
    
    static let padding = 8.0
    static let cornerRadius = 11.0
    static let maxHeight = 75.0
}

fileprivate struct ThumbShape: Shape {
    
    func path(in rect: CGRect) -> Path {
        var path = Path()

        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))

        return path
    }
    
}

struct RGBFieldSelector_Previews: PreviewProvider {
    struct ContanerView: View {
        
        @State var color = SPTRGBAColor(red: 1.0, green: 0.0, blue: 0.0)
        
        var body: some View {
            RGBColorSelector(rgbaColor: $color, channel: .red)
                .tint(.primarySelectionColor)
        }
    }
    
    static var previews: some View {
        ContanerView()
            .padding()
    }
}
