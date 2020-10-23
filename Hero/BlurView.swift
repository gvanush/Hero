//
//  BlurView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10/20/20.
//

import SwiftUI

struct BlurView: UIViewRepresentable {
    
    var style = UIBlurEffect.Style.systemMaterial
    
    typealias UIViewType = UIVisualEffectView
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
    }
    
}
