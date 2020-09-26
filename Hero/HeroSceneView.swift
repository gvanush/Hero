//
//  HeroSceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI
import MetalKit
import Metal

struct HeroSceneView: UIViewControllerRepresentable {
    
    @Environment(\.scene) private var scene
    
    func makeUIViewController(context: Context) -> HeroSceneViewController {
        HeroSceneViewController(scene: scene)
    }
    
    func updateUIViewController(_ uiViewController: HeroSceneViewController, context: Context) {
    }
    
    typealias UIViewControllerType = HeroSceneViewController
    
}
