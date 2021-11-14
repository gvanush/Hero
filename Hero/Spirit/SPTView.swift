//
//  SptViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/18/21.
//

import UIKit
import MetalKit
import SwiftUI

struct SPTView: UIViewControllerRepresentable {

    let scene: SPTScene
    @Binding var clearColor: MTLClearColor
    
    func makeUIViewController(context: Context) -> SPTViewController {
        SPTViewController(scene: scene)
    }
    
    func updateUIViewController(_ uiViewController: SPTViewController, context: Context) {
        uiViewController.mtkView.clearColor = clearColor
    }
    
    typealias UIViewControllerType = SPTViewController
    
}
