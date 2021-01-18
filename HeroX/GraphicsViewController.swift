//
//  GraphicsViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/18/21.
//

import UIKit
import MetalKit

class GraphicsViewController: UIViewController, MTKViewDelegate {
    
    init(scene: Scene, nibName: String?, bundle: Bundle?) {
        self.scene = scene
        super.init(nibName: nibName, bundle: bundle)
    }
    
    init?(scene: Scene, coder: NSCoder) {
        self.scene = scene
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        graphicsView = MTKView(frame: view.bounds, device: RenderingContext.device())
        graphicsView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        graphicsView.autoResizeDrawable = true
        graphicsView.colorPixelFormat = RenderingContext.colorPixelFormat()
        graphicsView.depthStencilPixelFormat = RenderingContext.depthPixelFormat()
        graphicsView.clearColor = UIColor.sceneBgrColor.mtlClearColor
        graphicsView.presentsWithTransaction = true
        graphicsView.delegate = self
        view.addSubview(graphicsView)
        
        updateViewportSize(graphicsView.drawableSize)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scene.isTurnedOn = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scene.isTurnedOn = false
    }
    
    private func updateViewportSize(_ size: CGSize) {
        renderingContext.viewportSize = size.simd2
        scene.viewCamera.camera.aspectRatio = Float(size.width / size.height)
    }
    
    // MARK: MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateViewportSize(size)
    }
    
    func draw(in view: MTKView) {
        
        // IMPROVEMENT: @Vanush preferably this should be done as late as possible (at least after command buffer is created)
        guard let renderPassDescriptor = graphicsView.currentRenderPassDescriptor else {
            return
        }
        
        renderingContext.renderPassDescriptor = renderPassDescriptor
        
        renderer.render(scene, context: renderingContext)
        
        if let drawable = graphicsView.currentDrawable {
            drawable.present()
        }
        
    }
    
    let renderer = Renderer.make()!
    private(set) var graphicsView: MTKView! = nil
    let scene: Scene
    private let renderingContext = RenderingContext()
}
