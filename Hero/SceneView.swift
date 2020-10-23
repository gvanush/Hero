//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI
import MetalKit
import Metal

struct SceneView: UIViewControllerRepresentable {
    
    @Environment(\.scene) private var scene
    
    func makeUIViewController(context: Context) -> SceneViewController {
        SceneViewController(scene: scene)
    }
    
    func updateUIViewController(_ uiViewController: SceneViewController, context: Context) {
    }
    
    typealias UIViewControllerType = SceneViewController
    
}
