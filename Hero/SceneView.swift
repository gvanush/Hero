//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI
import MetalKit
import Metal

class SceneViewModel: ObservableObject {
    
    @Environment(\.scene) var scene
    @Published var isInspectorVisible = true
    @Published var frameRate: Int = 60
    @Published var isPaused = false
    
    func setFullScreenMode(enabled: Bool, animated: Bool = false) {
        if animated {
            withAnimation {
                isInspectorVisible = !enabled
            }
        } else {
            isInspectorVisible = !enabled
        }
    }
    
}

struct SceneView: View {
    
    @ObservedObject private var model: SceneViewModel
    @EnvironmentObject private var rootViewModel: RootViewModel
    
    init(model: SceneViewModel) {
        self.model = model
    }
    
    var body: some View {
        ZStack {
            SceneViewControllerProxy(sceneViewModel: model, rootViewModel: rootViewModel)
                .ignoresSafeArea()
            if let selected = model.scene.selectedObject {
                Inspector(model: InspectorModel(sceneObject: selected))
                    .opacity(model.isInspectorVisible ? 1.0 : 0.0)
            }
        }
            .environmentObject(model)
    }
    
    struct SceneViewControllerProxy: UIViewControllerRepresentable {
        
        @ObservedObject var sceneViewModel: SceneViewModel
        let rootViewModel: RootViewModel
        
        func makeUIViewController(context: Context) -> SceneViewController {
            SceneViewController(scene: sceneViewModel.scene, sceneViewModel: sceneViewModel, rootViewModel: rootViewModel)
        }
        
        func updateUIViewController(_ uiViewController: SceneViewController, context: Context) {
            uiViewController.frameRate = sceneViewModel.frameRate
            uiViewController.isPaused = sceneViewModel.isPaused
        }
        
        typealias UIViewControllerType = SceneViewController
        
    }
}
