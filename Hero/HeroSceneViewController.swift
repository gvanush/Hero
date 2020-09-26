//
//  HeroSceneViewController.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

import UIKit
import MetalKit
import Metal

class HeroSceneViewController: UIViewController, MTKViewDelegate {
    
    init(scene: HeroScene) {
        self.scene = scene
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sceneView = MTKView(frame: view.bounds, device: RenderingContext.device())
        sceneView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        sceneView.autoResizeDrawable = true
        sceneView.colorPixelFormat = RenderingContext.colorPixelFormat()
        sceneView.clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        sceneView.delegate = self
        
        view.addSubview(sceneView)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderingContext.drawableSize = simd_float2(x: Float(size.width), y: Float(size.height))
        scene.viewportSize = renderingContext.drawableSize
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = sceneView.currentDrawable, let renderPassDescriptor = sceneView.currentRenderPassDescriptor else {
            return
        }
        
        renderingContext.drawable = drawable
        renderingContext.renderPassDescriptor = renderPassDescriptor
        
        scene.render(renderingContext)
    }
    

    var sceneView: MTKView!
    var scene: HeroScene
    var renderingContext = RenderingContext()
}
