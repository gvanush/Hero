//
//  RGBColorFieldSelector.swift
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

struct RGBColorFieldSelector: View {
    
    @Binding var rgbaColor: RGBAColor
    let component: RGBAColorComponent
    
    @State private var prevLocation: CGPoint?
    @State private var feedbackGenerator = UIImpactFeedbackGenerator()
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 8.0) {
                Text(String(format: "%.2f", componentValue))
                    .foregroundColor(.controlValue)
                VStack(spacing: 0.0) {
                    Capsule()
                        .fill(.linearGradient(colors: [startColor, endColor], startPoint: .leading, endPoint: .trailing))
                        .frame(height: 4.0)
                    thumb(geometry: geometry)
                }
                .contentShape(Rectangle())
                .gesture(dragGesture(geometry: geometry))
            }
        }
        .padding(.horizontal, Self.horizontalPadding)
        .padding(.vertical, Self.verticalPadding)
        .frame(maxWidth: .infinity, maxHeight: Self.maxHeight)
        .background(Material.thin)
        .cornerRadius(Self.cornerRadius)
        .shadow(radius: 1.0)
        .onAppear {
            feedbackGenerator.prepare()
        }
    }
    
    func thumb(geometry: GeometryProxy) -> some View {
        ThumbShape()
            .stroke(TintShapeStyle(), style: .init(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
            .background {
                ThumbShape()
                    .fill(color)
            }
            .frame(width: 32.0)
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
    
    var color: Color {
        .init(red: Double(rgbaColor.x), green: Double(rgbaColor.y), blue: Double(rgbaColor.z))
    }
    
    var componentValue: Float {
        rgbaColor[component.rawValue]
    }
    
    var startColor: Color {
        .init(red: Double(component == .red ? 0.0 : rgbaColor.x),
              green: Double(component == .green ? 0.0 : rgbaColor.y),
              blue: Double(component == .blue ? 0.0 : rgbaColor.z))
    }
    
    var endColor: Color {
        .init(red: Double(component == .red ? 1.0 : rgbaColor.x),
              green: Double(component == .green ? 1.0 : rgbaColor.y),
              blue: Double(component == .blue ? 1.0 : rgbaColor.z))
    }
    
    static let horizontalPadding = 24.0
    static let verticalPadding = 8.0
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
            RGBColorFieldSelector(rgbaColor: $color, component: .red)
                .tint(.primarySelectionColor)
        }
    }
    
    static var previews: some View {
        ContanerView()
            .padding()
    }
}
