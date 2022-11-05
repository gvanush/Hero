//
//  RGBColorSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.11.22.
//

import SwiftUI
import simd


enum RGBAColorComponent: Int {
    case red
    case green
    case blue
    case alpha
}

typealias RGBAColor = simd_float4

extension RGBAColor {
    
    func reded(_ red: Float) -> RGBAColor {
        var color = self
        color.x = red
        return color
    }
    
    func greened(_ green: Float) -> RGBAColor {
        var color = self
        color.y = green
        return color
    }
    
    func blued(_ blue: Float) -> RGBAColor {
        var color = self
        color.z = blue
        return color
    }
    
}

fileprivate let gradientColorSpace = Gradient.ColorSpace.device

struct RGBColorSelector: View {
    
    @Binding var rgbaColor: RGBAColor
    let component: RGBAColorComponent
    
    @State private var prevLocation: CGPoint?
    @State private var feedbackGenerator = UIImpactFeedbackGenerator(style: .light)
    
    var body: some View {
        HStack {
            HStack(spacing: 12.0) {
                HStack(spacing: 2.0) {
                    textForSecondaryComponent(secondaryComponent1)
                    trackForSecondaryComponent(secondaryComponent1)
                }
                HStack(spacing: 2.0) {
                    trackForSecondaryComponent(secondaryComponent2)
                    textForSecondaryComponent(secondaryComponent2)
                }
            }
            VStack {
                Text(String(format: "%.2f", componentValue))
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
        Gradient(colors: [startColor(component: component), endColor(component: component)])
            .colorSpace(gradientColorSpace)
    }
    
    func thumb(geometry: GeometryProxy) -> some View {
        RoundedRectangle(cornerRadius: 3.0)
            .fill(Color(rgba: rgbaColor))
            .frame(width: 8.0)
            .shadow(radius: 1.0)
            .offset(x: thumbOffset(geometry: geometry))
    }
    
    func thumbOffset(geometry: GeometryProxy) -> CGFloat {
        CGFloat(2.0 * componentValue - 1.0) * geometry.size.width * 0.5
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
                
                rgbaColor[component.rawValue] = newValue
                self.prevLocation = value.location
            }
            .onEnded { _ in
                prevLocation = nil
            }
    }
    
    var componentValue: Float {
        rgbaColor[component.rawValue]
    }
    
    func dragIndicator() -> some View {
        HLine()
            .stroke(style: StrokeStyle(lineWidth: 4.0, dash: [1, 4]))
            .foregroundColor(.primarySelectionColor)
            .frame(height: 4.0)
            .mask(LinearGradient(colors: [.black.opacity(0.0), .black, .black.opacity(0.0)], startPoint: .leading, endPoint: .trailing))
    }
    
    func textForSecondaryComponent(_ component: RGBAColorComponent) -> some View {
        Text(nameForSecondaryComponent(component))
            .font(.caption.monospaced())
            .foregroundColor(.secondary)
    }
    
    func trackForSecondaryComponent(_ component: RGBAColorComponent) -> some View {
        Capsule()
            .fill(.linearGradient(colors: [startColor(component: component), endColor(component: component)], startPoint: .bottom, endPoint: .top))
            .frame(width: 4.0)
    }
    
    func nameForSecondaryComponent(_ component: RGBAColorComponent) -> String {
        switch component {
        case .red:
            return "R"
        case .green:
            return "G"
        case .blue:
            return "B"
        case .alpha:
            return "A"
        }
    }
    
    var secondaryComponent1: RGBAColorComponent {
        switch component {
        case .red:
            return .green
        case .green:
            return .blue
        case .blue:
            return .red
        case .alpha:
            return .alpha
        }
    }
    
    var secondaryComponent2: RGBAColorComponent {
        switch component {
        case .red:
            return .blue
        case .green:
            return .red
        case .blue:
            return .green
        case .alpha:
            return .alpha
        }
    }
    
    func startColor(component: RGBAColorComponent) -> Color {
        switch component {
        case .red:
            return .init(rgba: rgbaColor.reded(0.0))
        case .green:
            return .init(rgba: rgbaColor.greened(0.0))
        case .blue:
            return .init(rgba: rgbaColor.blued(0.0))
        case .alpha:
            return .black
        }
    }
    
    func endColor(component: RGBAColorComponent) -> Color {
        switch component {
        case .red:
            return .init(rgba: rgbaColor.reded(1.0))
        case .green:
            return .init(rgba: rgbaColor.greened(1.0))
        case .blue:
            return .init(rgba: rgbaColor.blued(1.0))
        case .alpha:
            return .black
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
        
        @State var color = RGBAColor(x: 1.0, y: 0.0, z: 0.0, w: 1.0)
        
        var body: some View {
            RGBColorSelector(rgbaColor: $color, component: .red)
                .tint(.primarySelectionColor)
        }
    }
    
    static var previews: some View {
        ContanerView()
            .padding()
    }
}
