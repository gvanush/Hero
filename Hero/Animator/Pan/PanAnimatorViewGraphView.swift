//
//  PanAnimatorViewGraphView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.07.22.
//

import SwiftUI

class PanAnimatorViewGraphViewModel: AnimatorViewModel {
    
    var axis: SPTPanAnimatorSourceAxis {
        animator.source.pan.axis
    }
    
    func boundsSizeOnScreenSize(_ size: CGSize) -> CGSize {
        animator.source.pan.boundsSizeOnScreenSize(size)
    }
    
    func boundsOffsetOnScreenSize(_ size: CGSize) -> CGSize {
        animator.source.pan.boundsOffsetOnScreenSize(size)
    }
    
    func isInBounds(dragValue: DragGesture.Value, geometry: GeometryProxy) -> Bool {
        let normX = Float(dragValue.startLocation.x / geometry.size.width)
        let normY = 1.0 - Float(dragValue.startLocation.y / geometry.size.height)
        return normX >= animator.source.pan.bottomLeft.x && normX <= animator.source.pan.topRight.x && normY >= animator.source.pan.bottomLeft.y && normY <= animator.source.pan.topRight.y
    }
    
    func getAnimatorValue(dragValue: DragGesture.Value, geometry: GeometryProxy) -> Float? {
        var context = SPTAnimatorEvaluationContext()
        context.panLocation = .init(x: Float(dragValue.location.x / geometry.size.width), y: 1.0 - Float(dragValue.location.y / geometry.size.height))
        return getAnimatorValue(context: context)
    }
    
}

struct PanAnimatorViewGraphView: View {
    
    @StateObject var model: PanAnimatorViewGraphViewModel
    @GestureState private var isDragging = false
    @State private var dragValue: DragGesture.Value?
    @State private var shouldSample = false
    
    @State private var animatorLastValue: Float?
    
    @Environment(\.presentationMode) private var presentationMode
    
    
    var body: some View {
        GeometryReader { geometry in
            GeometryReader { dargAreaGeometry in
                ZStack {
                    Color.systemBackground
                    SignalGraphView(name: model.axis.displayName) {
                        animatorLastValue
                    }
                    .padding()
                    Rectangle()
                        .foregroundColor(.ultraLightAccentColor)
                        .frame(size: model.boundsSizeOnScreenSize(dargAreaGeometry.size))
                        .offset(model.boundsOffsetOnScreenSize(dargAreaGeometry.size))
                }
                .gesture(dragGesture(geometry: dargAreaGeometry, bottomSafeAreaInset: geometry.safeAreaInsets.bottom))
                .defersSystemGestures(on: .all)
                .onChange(of: isDragging) { [isDragging] newValue in
                    if newValue {
                        if !isDragging {
                            shouldSample = model.isInBounds(dragValue: dragValue!, geometry: dargAreaGeometry)
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
                    animatorLastValue = model.getAnimatorValue(dragValue: newDragValue, geometry: geometry)
                }
                
            })
            .onEnded({ newDragValue in
                if shouldSample {
                    animatorLastValue = model.getAnimatorValue(dragValue: newDragValue, geometry: geometry)
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
    
}

struct PanAnimatorViewSignalView_Previews: PreviewProvider {
    static var previews: some View {
        let animatorId = SPTAnimator.make(.init(name: "Pan.1", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one)))
        return PanAnimatorViewGraphView(model: .init(animatorId: animatorId))
    }
}
