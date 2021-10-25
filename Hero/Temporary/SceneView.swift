//
//  SceneView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.10.21.
//

import SwiftUI

struct SceneView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> SceneViewController {
        SceneViewController()
    }
    
    func updateUIViewController(_ uiViewController: SceneViewController, context: Context) {
        
    }
    
    typealias UIViewControllerType = SceneViewController
    
    
    
    
}
