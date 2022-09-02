//
//  PlayView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.09.22.
//

import SwiftUI


class PlayViewModel: ObservableObject {
    
    let scene: SPTScene
    let viewCameraObject: SPTObject
    
    init(scene: SPTScene, viewCameraObject: SPTObject) {
        self.scene = scene
        self.viewCameraObject = viewCameraObject
    }
}


struct PlayView: View {
    
    @ObservedObject var model: PlayViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    @GestureState private var isDragging = false
    @State private var dragValue: DragGesture.Value?
    @State private var shouldCheckForExit = true
    
    
    var body: some View {
        GeometryReader { geometry in
            Group {
                GeometryReader { sptViewGeometry in
                    SPTView(scene: model.scene, clearColor: UIColor.lightGray.mtlClearColor, viewCameraObject: model.viewCameraObject, lookCategories: LookCategories.userCreated.rawValue)
                        .gesture(dragGesture(geometry: sptViewGeometry, bottomSafeAreaInset: geometry.safeAreaInsets.bottom))
                        .defersSystemGestures(on: .all)
                }
            }
            .ignoresSafeArea()
            .statusBarHidden()
        }
        .onChange(of: isDragging) { newValue in
            if !newValue {
                shouldCheckForExit = true
                dragValue = nil
            }
        }
    }
    
    func dragGesture(geometry: GeometryProxy, bottomSafeAreaInset: CGFloat) -> some Gesture {
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
                    dragValue = newDragValue
                }
            })
            .onEnded({ value in
                let bounds = geometry.frame(in: .local)
                let exitStartRect = bounds.inset(by: .init(top: bounds.height - bottomSafeAreaInset, left: 0.0, bottom: 0.0, right: 0.0))
                if shouldCheckForExit && exitStartRect.contains(value.startLocation) {
                    presentationMode.wrappedValue.dismiss()
                }
            })
    }
}
