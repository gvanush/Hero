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
    let clearColor: MTLClearColor
    let viewCameraEntity: spt_entity
    
    func makeUIViewController(context: Context) -> SPTViewController {
        let vc = SPTViewController(scene: scene)
        vc.mtkView.clearColor = clearColor
        vc.viewCameraEntity = viewCameraEntity
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SPTViewController, context: Context) {
        uiViewController.mtkView.clearColor = clearColor
        uiViewController.viewCameraEntity = viewCameraEntity
    }
    
    typealias UIViewControllerType = SPTViewController
    
}
