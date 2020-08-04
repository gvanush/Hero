//
//  CanvasViewController.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

import UIKit
import MetalKit
import Metal

class CanvasViewController: UIViewController, MTKViewDelegate {
    
    init(canvas: Canvas) {
        self.canvas = canvas
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        canvasView = MTKView(frame: view.bounds, device: RenderingContext.device())
        canvasView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        canvasView.autoResizeDrawable = true
        canvasView.colorPixelFormat = RenderingContext.colorPixelFormat()
        canvasView.clearColor = MTLClearColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0)
        canvasView.delegate = self
        
        view.addSubview(canvasView)
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        renderingContext.drawableSize = simd_float2(x: Float(size.width), y: Float(size.height))
        canvas.viewportSize = renderingContext.drawableSize
    }
    
    func draw(in view: MTKView) {
        
        guard let drawable = canvasView.currentDrawable, let renderPassDescriptor = canvasView.currentRenderPassDescriptor else {
            return
        }
        
        renderingContext.drawable = drawable
        renderingContext.renderPassDescriptor = renderPassDescriptor
        
        canvas.render(renderingContext)
    }
    

    var canvasView: MTKView!
    var canvas: Canvas
    var renderingContext = RenderingContext()
}
