//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/27/20.
//

import SwiftUI
import MetalKit
import Metal

struct WorldView: UIViewRepresentable {
    
    func makeUIView(context: Context) -> MTKView {
        MTKView(frame: .zero, device: MTLCreateSystemDefaultDevice())
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        
    }
    
}
