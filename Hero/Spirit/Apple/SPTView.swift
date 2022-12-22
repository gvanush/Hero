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

    // Needs to be @State to keep the scene alive as long as the view controller is
    @State var scene: SPTSceneProxy
    
    let clearColor: MTLClearColor
    let viewCameraEntity: SPTEntity
    
    private var isRenderingPaused = false
    private var lookCategories: SPTLookCategories = kSPTLookCategoriesAll
    
    init(scene: SPTSceneProxy, clearColor: MTLClearColor, viewCameraEntity: SPTEntity) {
        self.scene = scene
        self.clearColor = clearColor
        self.viewCameraEntity = viewCameraEntity
    }
    
    func makeUIViewController(context: Context) -> SPTViewController {
        let vc = SPTViewController(sceneHandle: scene.handle)
        updateVC(vc)
        return vc
    }
    
    func updateUIViewController(_ vc: SPTViewController, context: Context) {
        updateVC(vc)
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
        vc.viewCameraEntity = viewCameraEntity
    }
    
    typealias UIViewControllerType = SPTViewController
    
}
