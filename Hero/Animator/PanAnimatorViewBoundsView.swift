//
//  PanAnimatorViewBoundsView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.07.22.
//

import SwiftUI

class PanAnimatorViewBoundsViewModel: ObservableObject {
    
    let animator: SPTAnimator
    
    init(animator: SPTAnimator) {
        self.animator = animator
    }
    
    func valueAt(_ p: CGPoint, screenSize: CGSize) -> Float {
        switch animator.source.pan.axis {
        case .horizontal:
            return SPTAnimatorGetValue(animator, Float(p.x / screenSize.width))
        case .vertical:
            return SPTAnimatorGetValue(animator, Float(1.0 - p.y / screenSize.height))
        }
    }
    
}

struct PanAnimatorViewBoundsView: View {
    
    @ObservedObject var model: PanAnimatorViewBoundsViewModel
    @GestureState private var isDragging = false
    @State private var dragValue: DragGesture.Value?
    @State private var shouldCheckForExit = true
    @Environment(\.presentationMode) private var presentationMode
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.systemBackground
                Rectangle()
                    .foregroundColor(.gestureSignalArea)
                    .frame(size: model.animator.source.pan.boundsSizeOnScreenSize(geometry.size))
                    .offset(model.animator.source.pan.boundsOffsetOnScreenSize(geometry.size))
                if let dragValue = dragValue {
                    HStack {
                        Image(systemName: "waveform.path.ecg")
                            .foregroundColor(.secondaryLabel)
                        Text(String(format: "%.2f", model.valueAt(dragValue.location, screenSize: geometry.size)))
                            .foregroundColor(.secondaryLabel)
                    }
                    .offset(.init(width: dragValue.location.x - 0.5 * geometry.size.width, height: dragValue.location.y - 0.5 * geometry.size.height + Self.signalTextVerticalOffset))
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
            }
        }
    }
    
    func dragGesture(geometry: GeometryProxy) -> some Gesture {
        DragGesture(minimumDistance: 0.0)
            .updating($isDragging, body: { _, state, _ in
                state = true
            })
            .onChanged({ newValue in
                if let value = dragValue {
                    let delta = CGSize(width: newValue.translation.width - value.translation.width, height: newValue.translation.height - value.translation.height)
                    if delta.height > 0.0 || abs(delta.height) < abs(delta.width) {
                        shouldCheckForExit = false
                    }
                }
                dragValue = newValue
            })
            .onEnded({ value in
                let bounds = geometry.frame(in: .local)
                let exitStartRect = bounds.inset(by: .init(top: bounds.height - Self.exitStartRectHeight, left: 0.0, bottom: 0.0, right: 0.0))
                if shouldCheckForExit && exitStartRect.contains(value.startLocation) {
                    presentationMode.wrappedValue.dismiss()
                }
                
            })
    }
    
    static let exitStartRectHeight = 34.0
    static let signalTextVerticalOffset = -65.0
}

struct PanAnimatorViewBoundsView_Previews: PreviewProvider {
    static var previews: some View {
        PanAnimatorViewBoundsView(model: PanAnimatorViewBoundsViewModel(animator: SPTAnimator(name: "Pan 1", source: SPTAnimatorSourceMakePan(.horizontal, .zero, .one))))
    }
}
