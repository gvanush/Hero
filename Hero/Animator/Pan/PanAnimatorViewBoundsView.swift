//
//  PanAnimatorViewBoundsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.07.22.
//

import SwiftUI

class PanAnimatorViewBoundsViewModel: ObservableObject {
    
    let animatorId: SPTAnimatorId
    
    init(animatorId: SPTAnimatorId) {
        self.animatorId = animatorId
    }
    
    var animator: SPTAnimator {
        SPTAnimator.get(id: animatorId)
    }
    
    func valueAt(_ p: CGPoint, screenSize: CGSize) -> Float {
        var context = SPTAnimatorEvaluationContext()
        context.panLocation = .init(x: Float(p.x / screenSize.width), y: Float(1.0 - p.y / screenSize.height))
        return SPTAnimator.evaluateValue(id: animatorId, context: context)
    }
    
    func isInBounds(point: CGPoint, screenSize: CGSize) -> Bool {
        let normX = Float(point.x / screenSize.width)
        let normY = 1.0 - Float(point.y / screenSize.height)
        return normX >= animator.source.pan.bottomLeft.x && normX <= animator.source.pan.topRight.x && normY >= animator.source.pan.bottomLeft.y && normY <= animator.source.pan.topRight.y
    }
}

struct PanAnimatorViewBoundsView: View {
    
    @ObservedObject var model: PanAnimatorViewBoundsViewModel
    @GestureState private var isDragging = false
    @State private var dragValue: DragGesture.Value?
    @State private var showsAnimatorValue = false
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            GeometryReader { dragAreaGeometry in
                ZStack {
                    Color.systemBackground
                    Rectangle()
                        .foregroundColor(.ultraLightAccentColor)
                        .frame(size: model.animator.source.pan.boundsSizeOnScreenSize(dragAreaGeometry.size))
                        .offset(model.animator.source.pan.boundsOffsetOnScreenSize(dragAreaGeometry.size))
                    if showsAnimatorValue {
                        HStack {
                            Image(systemName: "waveform.path.ecg")
                                .foregroundColor(.secondaryLabel)
                            Text(String(format: "%.2f", model.valueAt(dragValue!.location, screenSize: dragAreaGeometry.size)))
                                .foregroundColor(.secondaryLabel)
                        }
                        .offset(.init(width: dragValue!.location.x - 0.5 * dragAreaGeometry.size.width, height: dragValue!.location.y - 0.5 * dragAreaGeometry.size.height + Self.signalTextVerticalOffset))
                    }
                }
                .gesture(dragGesture(geometry: dragAreaGeometry, bottomSafeAreaInset: geometry.safeAreaInsets.bottom))
                .defersSystemGestures(on: .all)
                .onChange(of: isDragging) { [isDragging] newValue in
                    if newValue {
                        if !isDragging {
                            showsAnimatorValue = model.isInBounds(point: dragValue!.startLocation, screenSize: dragAreaGeometry.size)
                        }
                    } else {
                        dragValue = nil
                        showsAnimatorValue = false
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
            })
            .onEnded({ newDragValue in
                
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
    
    static let signalTextVerticalOffset = -65.0
}

struct PanAnimatorViewBoundsView_Previews: PreviewProvider {
    static var previews: some View {
        let animatorId = SPTAnimator.make(.init(name: "Pan 1", source: .init(panWithAxis: .horizontal, bottomLeft: .zero, topRight: .one)))
        return PanAnimatorViewBoundsView(model: PanAnimatorViewBoundsViewModel(animatorId: animatorId))
    }
}
