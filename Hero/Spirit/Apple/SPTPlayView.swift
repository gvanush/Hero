//
//  SPTPlayView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.09.22.
//

import SwiftUI


struct SPTPlayView: UIViewControllerRepresentable {
    
    let scene: SPTPlayableSceneProxy
    let clearColor: MTLClearColor
    let viewCameraEntity: SPTEntity
    
    private var panLocation: CGPoint?
    private var lookCategories: SPTLookCategories = kSPTLookCategoriesAll
    
    init(scene: SPTPlayableSceneProxy, clearColor: MTLClearColor, viewCameraEntity: SPTEntity) {
        self.scene = scene
        self.clearColor = clearColor
        self.viewCameraEntity = viewCameraEntity
    }
    
    func makeUIViewController(context: Context) -> SPTPlayViewController {
        let vc = SPTPlayViewController(sceneHandle: scene.handle)
        updateVC(vc)
        return vc
    }
    
    func updateUIViewController(_ vc: SPTPlayViewController, context: Context) {
        updateVC(vc)
    }
    
    func panLocation(_ location: CGPoint?) -> SPTPlayView {
        var view = self
        view.panLocation = location
        return view
    }
    
    func lookCategories(_ categories: SPTLookCategories) -> SPTPlayView {
        var view = self
        view.lookCategories = categories
        return view
    }
    
    private func updateVC(_ vc: SPTPlayViewController) {
        vc.mtkView.clearColor = clearColor
        vc.renderingContext.lookCategories = lookCategories
        vc.viewCameraEntity = viewCameraEntity
        if let loc = panLocation {
            vc.panLocation = .init(cgPoint: loc)
        } else {
            vc.panLocation = nil
        }
    }
    
    typealias UIViewControllerType = SPTPlayViewController
    
}
