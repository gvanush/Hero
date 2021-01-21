//
//  GraphicsViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/18/21.
//

import UIKit
import MetalKit

class GraphicsViewController: UIViewController, MTKViewDelegate {
    
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
        scene?.isTurnedOn = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scene?.isTurnedOn = false
    }
    
    private func updateViewportSize(_ size: CGSize) {
        renderingContext.viewportSize = size.simd2
        scene?.viewCamera.camera.aspectRatio = Float(size.width / size.height)
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
        
        renderer.render(scene!, context: renderingContext)
        
        if let drawable = graphicsView.currentDrawable {
            drawable.present()
        }
        
    }
    
    var scene: Scene? {
        willSet {
            
            guard isVisible else { return }
            
            if let scene = scene {
                scene.isTurnedOn = false
            }
            if let newScene = scene {
                newScene.isTurnedOn = true
                graphicsView.isPaused = false
            } else {
                graphicsView.isPaused = true
            }
        }
        
        didSet {
            updateViewportSize(graphicsView.drawableSize)
        }
    }
    
    let renderer = Renderer.make()!
    private(set) var graphicsView: MTKView! = nil
    private let renderingContext = RenderingContext()
}
