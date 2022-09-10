//
//  PlayView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.09.22.
//

import SwiftUI


class PlayViewModel: ObservableObject {
    
    let scene: SPTPlayableSceneProxy
    let viewCameraEntity: SPTEntity
    
    init(scene: SPTPlayableSceneProxy, viewCameraEntity: SPTEntity) {
        self.scene = scene
        self.viewCameraEntity = viewCameraEntity
    }
}


struct PlayView: View {
    
    @ObservedObject var model: PlayViewModel
    
    @Environment(\.presentationMode) private var presentationMode
    @GestureState private var isDragging = false
    @State private var dragValue: DragGesture.Value?
    
    
    var body: some View {
        GeometryReader { geometry in
            GeometryReader { dargViewGeometry in
                SPTPlayView(scene: model.scene, clearColor: UIColor.lightGray.mtlClearColor, viewCameraEntity: model.viewCameraEntity)
                    .lookCategories(LookCategories.userCreated.rawValue)
                    .panLocation(dragValue?.location)
                    .gesture(dragGesture(geometry: dargViewGeometry, bottomSafeAreaInset: geometry.safeAreaInsets.bottom))
                    .defersSystemGestures(on: .all)
            }
            .ignoresSafeArea()
        }
        .statusBarHidden()
        .onChange(of: isDragging) { newValue in
            if !newValue {
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
}
