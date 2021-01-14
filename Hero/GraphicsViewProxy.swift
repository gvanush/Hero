//
//  GraphicsViewProxy.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11/16/20.
//

import Foundation
import SwiftUI

class GraphicsViewController: UIViewController, MTKViewDelegate, UIGestureRecognizerDelegate {
    
    init(viewModel: GraphicsViewModel) {
        self.viewModel = viewModel
        self.sceneNavigationController = SceneNavigationController(scene: viewModel.scene, sceneView: viewModel.view)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) not supported")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.view.frame = view.bounds
        viewModel.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        viewModel.view.autoResizeDrawable = true
        viewModel.view.colorPixelFormat = RenderingContext.colorPixelFormat()
        viewModel.view.depthStencilPixelFormat = RenderingContext.depthPixelFormat()
        viewModel.view.clearColor = UIColor.sceneBgrColor.mtlClearColor
        viewModel.view.presentsWithTransaction = true
        viewModel.view.delegate = self
        view.addSubview(viewModel.view)
        
        updateViewportSize(SIMD2<Float>(x: Float(viewModel.view.drawableSize.width), y: Float(viewModel.view.drawableSize.height)))
        
        setupGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.scene.isTurnedOn = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        viewModel.scene.isTurnedOn = false
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateViewportSize(SIMD2<Float>(x: Float(size.width), y: Float(size.height)))
    }
    
    func draw(in view: MTKView) {
        
        // IMPROVEMENT: @Vanush preferably this should be done as late as possible (at least after command buffer is created)
        guard let renderPassDescriptor = viewModel.view.currentRenderPassDescriptor else {
            return
        }
        
        renderingContext.renderPassDescriptor = renderPassDescriptor
        
        viewModel.renderer.render(viewModel.scene, context: renderingContext)
        
        if let drawable = viewModel.view.currentDrawable {
            drawable.present()
        }
        
    }
    
    private func updateViewportSize(_ size: SIMD2<Float>) {
        renderingContext.viewportSize = size
        viewModel.scene.viewCamera.camera.aspectRatio = size.x / size.y
    }
    
    private func setupGestures() {
        let tapGR = UITapGestureRecognizer(target: sceneNavigationController, action: #selector(SceneNavigationController.onTap))
        viewModel.view.addGestureRecognizer(tapGR)
        
        panGR = UIPanGestureRecognizer(target: sceneNavigationController, action: #selector(SceneNavigationController.onPan))
        panGR.delegate = self
        panGR.maximumNumberOfTouches = 1
        viewModel.view.addGestureRecognizer(panGR)
        
        let twoFingerPanGR = UIPanGestureRecognizer(target: sceneNavigationController, action: #selector(SceneNavigationController.onTwoFingerPan))
        twoFingerPanGR.delegate = self
        twoFingerPanGR.minimumNumberOfTouches = 2
        twoFingerPanGR.maximumNumberOfTouches = 2
        viewModel.view.addGestureRecognizer(twoFingerPanGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: sceneNavigationController, action: #selector(SceneNavigationController.onPinch))
        pinchGR.delegate = self
        viewModel.view.addGestureRecognizer(pinchGR)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if panGR === gestureRecognizer || panGR === otherGestureRecognizer {
            return false
        }
        return true
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            viewModel.view.clearColor = UIColor.sceneBgrColor.mtlClearColor
        }
    }
    
    @ObservedObject var viewModel: GraphicsViewModel
    fileprivate var sceneNavigationController: SceneNavigationController
    private var renderingContext = RenderingContext()
    private var panGR: UIPanGestureRecognizer!
}

class GraphicsViewModel: ObservableObject {
    
    let scene: Hero.Scene
    let renderer: Renderer
    
    init(scene: Hero.Scene, renderer: Renderer) {
        self.scene = scene
        self.renderer = renderer
    }
    
    var preferredFramesPerSecond: Int {
        set { view.preferredFramesPerSecond = newValue }
        get { view.preferredFramesPerSecond }
    }
    
    var isPaused: Bool {
        set { view.isPaused = newValue }
        get { view.isPaused }
    }
    
    fileprivate let view = MTKView(frame: CGRect.zero, device: RenderingContext.device())
}

struct GraphicsViewProxy: UIViewControllerRepresentable {
    
    @StateObject var model: GraphicsViewModel
    @Binding var isNavigating: Bool
    
    func makeUIViewController(context: Context) -> GraphicsViewController {
        let graphicsVC = GraphicsViewController(viewModel: model)
        graphicsVC.sceneNavigationController.delegate = context.coordinator
        return graphicsVC
    }
    
    func updateUIViewController(_ uiViewController: GraphicsViewController, context: Context) {
    }
    
    typealias UIViewControllerType = GraphicsViewController
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: SceneNavigationControllerDelegate {
        
        var parent: GraphicsViewProxy
        
        init(_ graphicsViewProxy: GraphicsViewProxy) {
            parent = graphicsViewProxy
        }
        
        func sceneNavigationControllerWillStartNavigation(_ controller: SceneNavigationController) {
            parent.isNavigating = true
        }
        
        func sceneNavigationControllerWillEndNavigation(_ controller: SceneNavigationController) {
            parent.isNavigating = false
        }
        
        
    }
    
}
