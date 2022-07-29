//
//  PanAnimatorViewSignalView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.07.22.
//

import SwiftUI


struct PanAnimatorViewSignalView: View {
    
    let animator: SPTAnimator
    let signal: PanAnimatorSignal
    @GestureState private var isDragging = false
    @State private var dragValue: DragGesture.Value?
    @State private var shouldCheckForExit = true
    
    @State private var signalLastValue: Float?
    
    @Environment(\.presentationMode) private var presentationMode
    
    init(animatorId: SPTAnimatorId, signal: PanAnimatorSignal) {
        self.animator = SPTAnimatorGet(animatorId)
        self.signal = signal
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.systemBackground
                Rectangle()
                    .foregroundColor(.gestureSignalArea)
                    .frame(size: animator.boundsSizeOnScreenSize(geometry.size))
                    .offset(animator.boundsOffsetOnScreenSize(geometry.size))
                SignalGraphView(name: signal.displayName) {
                    signalLastValue
                }
            }
            .gesture(dragGesture(geometry: geometry))
            .defersSystemGestures(on: .all)
        }
        .ignoresSafeArea()
        .statusBarHidden()
        .onChange(of: isDragging) { newValue in
            if !newValue {
                shouldCheckForExit = true
                dragValue = nil
                signalLastValue = nil
            }
        }
    }
    
    func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .updating($isDragging, body: { _, state, _ in
                state = true
            })
            .onChanged({ newDragValue in
                if let value = dragValue {
                    let delta = CGSize(width: newDragValue.translation.width - value.translation.width, height: newDragValue.translation.height - value.translation.height)
                    if delta.height > 0.0 || abs(delta.height) < abs(delta.width) {
                        shouldCheckForExit = false
                    }
                }
                
                dragValue = newDragValue
                signalLastValue = signalValue(dragValue: newDragValue, geometry: geometry)
                
            })
            .onEnded({ newDragValue in
                let bounds = geometry.frame(in: .local)
                let exitStartRect = bounds.inset(by: .init(top: bounds.height - Self.exitStartRectHeight, left: 0.0, bottom: 0.0, right: 0.0))
                if shouldCheckForExit && exitStartRect.contains(newDragValue.startLocation) {
                    presentationMode.wrappedValue.dismiss()
                }
                
                signalLastValue = signalValue(dragValue: newDragValue, geometry: geometry)
            })
    }
    
    func signalValue(dragValue: DragGesture.Value, geometry: GeometryProxy) -> Float {
        switch signal {
        case .horizontal:
            return SPTAnimatorGetSignalX(animator, Float(dragValue.location.x / geometry.size.width))
        case .vertical:
            return SPTAnimatorGetSignalY(animator, 1.0 - Float(dragValue.location.y / geometry.size.height))
        }
    }
    
    static let exitStartRectHeight = 34.0
    static let signalTextVerticalOffset = -65.0
    
}

struct PanAnimatorViewSignalView_Previews: PreviewProvider {
    static var previews: some View {
        PanAnimatorViewSignalView(animatorId: SPTAnimatorMake(.init(name: "Pan 1")), signal: .horizontal)
    }
}
