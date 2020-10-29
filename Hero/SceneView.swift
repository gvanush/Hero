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
    
    @Published var isObjectInspectorVisible = true
    @Published var frameRate: Int = 60
    @Published var isPaused = false
    
    func setFullScreenMode(enabled: Bool, animated: Bool = false) {
        if animated {
            withAnimation {
                isObjectInspectorVisible = !enabled
            }
        } else {
            isObjectInspectorVisible = !enabled
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
            ObjectInspector()
                .opacity(model.isObjectInspectorVisible ? 1.0 : 0.0)
        }
            .environmentObject(model)
    }
    
    struct SceneViewControllerProxy: UIViewControllerRepresentable {
        
        @ObservedObject var sceneViewModel: SceneViewModel
        let rootViewModel: RootViewModel
        @Environment(\.scene) private var scene
        
        func makeUIViewController(context: Context) -> SceneViewController {
            SceneViewController(scene: scene, rootViewModel: rootViewModel, sceneViewModel: sceneViewModel)
        }
        
        func updateUIViewController(_ uiViewController: SceneViewController, context: Context) {
            uiViewController.frameRate = sceneViewModel.frameRate
            uiViewController.isPaused = sceneViewModel.isPaused
        }
        
        typealias UIViewControllerType = SceneViewController
        
    }
}
