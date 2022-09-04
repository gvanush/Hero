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
    
    private var isRenderingPaused = false
    private var panLocation: CGPoint?
    private var lookCategories: SPTLookCategories = kSPTLookCategoriesAll
    
    init(scene: SPTScene, clearColor: MTLClearColor, viewCameraObject: SPTObject) {
        self.scene = scene
        self.clearColor = clearColor
        self.viewCameraObject = viewCameraObject
    }
    
    func makeUIViewController(context: Context) -> SPTViewController {
        let vc = SPTViewController(scene: scene)
        updateVC(vc)
        return vc
    }
    
    func updateUIViewController(_ vc: SPTViewController, context: Context) {
        updateVC(vc)
    }
    
    func panLocation(_ location: CGPoint?) -> SPTView {
        var view = self
        view.panLocation = location
        return view
    }
    
    func renderingPaused(_ paused: Bool) -> SPTView {
        var view = self
        view.isRenderingPaused = paused
        return view
    }
    
    func lookCategories(_ categories: SPTLookCategories) -> SPTView {
        var view = self
        view.lookCategories = categories
        return view
    }
    
    private func updateVC(_ vc: SPTViewController) {
        vc.mtkView.clearColor = clearColor
        vc.setRenderingPaused(isRenderingPaused)
        vc.renderingContext.lookCategories = lookCategories
        vc.viewCameraObject = viewCameraObject
        if let loc = panLocation {
            vc.panLocation = .init(cgPoint: loc)
        } else {
            vc.panLocation = nil
        }
    }
    
    typealias UIViewControllerType = SPTViewController
    
}
