//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI
import MetalKit
import Metal

struct CanvasView: UIViewControllerRepresentable {
    
    @Environment(\.canvas) var canvas
    
    func makeUIViewController(context: Context) -> CanvasViewController {
        return CanvasViewController(canvas: canvas)
    }
    
    func updateUIViewController(_ uiViewController: CanvasViewController, context: Context) {
    }
    
    typealias UIViewControllerType = CanvasViewController
    
}
