//
//  PanAnimatorViewGraphView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.07.22.
//

import SwiftUI


struct PanAnimatorViewGraphView: View {
    
    let animator: SPTAnimator
    @GestureState private var isDragging = false
    @State private var dragValue: DragGesture.Value?
    @State private var shouldSample = false
    
    @State private var animatorLastValue: Float?
    
    @Environment(\.presentationMode) private var presentationMode
    
    init(animatorId: SPTAnimatorId) {
        self.animator = SPTAnimatorGet(animatorId)
        assert(animator.source.type == .pan)
    }
    
    var body: some View {
        GeometryReader { geometry in
            GeometryReader { dargAreaGeometry in
                ZStack {
                    Color.systemBackground
                    SignalGraphView(name: animator.source.pan.axis.displayName) {
                        animatorLastValue
                    }
                    Rectangle()
                        .foregroundColor(.ultraLightAccentColor)
                        .frame(size: animator.source.pan.boundsSizeOnScreenSize(dargAreaGeometry.size))
                        .offset(animator.source.pan.boundsOffsetOnScreenSize(dargAreaGeometry.size))
                }
                .gesture(dragGesture(geometry: dargAreaGeometry, bottomSafeAreaInset: geometry.safeAreaInsets.bottom))
                .defersSystemGestures(on: .all)
                .onChange(of: isDragging) { [isDragging] newValue in
                    if newValue {
                        if !isDragging {
                            shouldSample = isInBounds(dragValue: dragValue!, geometry: dargAreaGeometry)
                        }
                    } else {
                        dragValue = nil
                        animatorLastValue = nil
                        shouldSample = false
                    }
                }
            }
            .ignoresSafeArea()
        }
        .statusBarHidden()
    }
    
    func dragGesture(geometry: GeometryProxy, bottomSafeAreaInset: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .updating($isDragging, body: { _, state, _ in
                state = true
            })
            .onChanged({ newDragValue in
                
                dragValue = newDragValue
                
                if shouldSample {
                    animatorLastValue = animatorValue(dragValue: newDragValue, geometry: geometry)
                }
                
            })
            .onEnded({ newDragValue in
                if shouldSample {
                    animatorLastValue = animatorValue(dragValue: newDragValue, geometry: geometry)
                }
                
                guard let value = dragValue else { return }
                let delta = CGSize(width: newDragValue.translation.width - value.translation.width, height: newDragValue.translation.height - value.translation.height)
                if delta.height > 0.0 || abs(delta.height) < abs(delta.width) {
                    return
                }
                
                let bounds = geometry.frame(in: .local)
                let exitStartRect = bounds.inset(by: .init(top: bounds.height - bottomSafeAreaInset, left: 0.0, bottom: 0.0, right: 0.0))
                if exitStartRect.contains(newDragValue.startLocation) {
                    presentationMode.wrappedValue.dismiss()
                }
                
            })
    }
    
    func isInBounds(dragValue: DragGesture.Value, geometry: GeometryProxy) -> Bool {
        let normX = Float(dragValue.startLocation.x / geometry.size.width)
        let normY = 1.0 - Float(dragValue.startLocation.y / geometry.size.height)
        return normX >= animator.source.pan.bottomLeft.x && normX <= animator.source.pan.topRight.x && normY >= animator.source.pan.bottomLeft.y && normY <= animator.source.pan.topRight.y
    }
    
    func animatorValue(dragValue: DragGesture.Value, geometry: GeometryProxy) -> Float {
        var context = SPTAnimatorEvaluationContext()
        context.panLocation = .init(x: Float(dragValue.location.x / geometry.size.width), y: 1.0 - Float(dragValue.location.y / geometry.size.height))
        return SPTAnimatorEvaluateValue(animator, context)
    }
    
}

struct PanAnimatorViewSignalView_Previews: PreviewProvider {
    static var previews: some View {
        PanAnimatorViewGraphView(animatorId: SPTAnimatorMake(.init(name: "Pan 1", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one))))
    }
}
