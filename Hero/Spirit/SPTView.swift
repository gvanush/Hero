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
    @Binding var clearColor: MTLClearColor
    
    func makeUIViewController(context: Context) -> SPTViewController {
        SPTViewController(scene: scene)
    }
    
    func updateUIViewController(_ uiViewController: SPTViewController, context: Context) {
        uiViewController.mtkView.clearColor = clearColor
    }
    
    typealias UIViewControllerType = SPTViewController
    
}

class SPTViewController: UIViewController, MTKViewDelegate {
    
    init(scene: SPTScene) {
        self.scene = scene
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        mtkView = MTKView(frame: view.bounds, device: RenderingContext.device())
        mtkView = MTKView(frame: view.bounds, device: MTLCreateSystemDefaultDevice())
        mtkView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mtkView.autoResizeDrawable = true
//        mtkView.colorPixelFormat = RenderingContext.colorPixelFormat()
//        mtkView.depthStencilPixelFormat = RenderingContext.depthPixelFormat()
        mtkView.clearColor = UIColor.sceneBgrColor.mtlClearColor
        mtkView.presentsWithTransaction = true
        mtkView.delegate = self
        view.insertSubview(mtkView, at: 0)
        
        updateViewportSize(mtkView.drawableSize)
        
    }
    
    private func updateViewportSize(_ size: CGSize) {
//        renderingContext.viewportSize = size.float2
//        scene.viewCamera.camera!.aspectRatio = Float(size.width / size.height)
    }
    
    // MARK: MTKViewDelegate
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateViewportSize(size)
    }
    
    func draw(in view: MTKView) {
        
        // IMPROVEMENT: @Vanush preferably this should be done as late as possible (at least after command buffer is created)
//        guard let renderPassDescriptor = mtkView.currentRenderPassDescriptor else {
//            return
//        }
        
//        renderingContext.renderPassDescriptor = renderPassDescriptor
//
//        renderer.render(scene, context: renderingContext)
        
        if let drawable = mtkView.currentDrawable {
            drawable.present()
        }
        
    }
    
    let scene: SPTScene
    
    private(set) var mtkView: MTKView! = nil
}

