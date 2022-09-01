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
    let viewCameraObject: SPTObject
    var isRenderingPaused = false
    let lookCategories = kSPTLookCategoriesAll
    
    func makeUIViewController(context: Context) -> SPTViewController {
        let vc = SPTViewController(scene: scene)
        vc.mtkView.clearColor = clearColor
        vc.viewCameraObject = viewCameraObject
        vc.renderingContext.lookCategories = lookCategories
        return vc
    }
    
    func updateUIViewController(_ uiViewController: SPTViewController, context: Context) {
        uiViewController.mtkView.clearColor = clearColor
        uiViewController.setRenderingPaused(isRenderingPaused)
        uiViewController.viewCameraObject = viewCameraObject
    }
    
    typealias UIViewControllerType = SPTViewController
    
}
