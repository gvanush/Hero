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
    
    @Published var isObjectToolbarVisible = true
    
    func setFullScreenMode(enabled: Bool, animated: Bool = false) {
        if animated {
            withAnimation {
                isObjectToolbarVisible = !enabled
            }
        } else {
            isObjectToolbarVisible = !enabled
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
            ObjectToolbar()
                .opacity(model.isObjectToolbarVisible ? 1.0 : 0.0)
        }
    }
    
    struct SceneViewControllerProxy: UIViewControllerRepresentable {
        
        let sceneViewModel: SceneViewModel
        let rootViewModel: RootViewModel
        @Environment(\.scene) private var scene
        
        func makeUIViewController(context: Context) -> SceneViewController {
            SceneViewController(scene: scene, rootViewModel: rootViewModel, sceneViewModel: sceneViewModel)
        }
        
        func updateUIViewController(_ uiViewController: SceneViewController, context: Context) {
        }
        
        typealias UIViewControllerType = SceneViewController
        
    }
}
