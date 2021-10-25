//
//  GraphicsViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/18/21.
//

import UIKit
import MetalKit

protocol GraphicsViewFrameListener: AnyObject {
    func onFrameUpdate(deltaTime: Float)
}

class GraphicsViewFrameUpdater: Updater, GraphicsViewFrameListener, NSCopying {
    
    fileprivate init(graphicsViewController: GraphicsViewController?) {
        self.graphicsViewController = graphicsViewController
    }
    
    // MARK: Updater
    func start() {
        graphicsViewController?.addFrameListener(self)
    }
    
    func stop() {
        graphicsViewController?.removeFrameListener(self)
    }
    
    var callback: ((Float) -> Void)?
    
    // MARK: GraphicsViewFrameListener
    func onFrameUpdate(deltaTime: Float) {
        callback?(deltaTime)
    }
    
    // MARK: NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        GraphicsViewFrameUpdater(graphicsViewController: graphicsViewController)
    }
    
    private weak var graphicsViewController: GraphicsViewController?
    
}

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
        view.insertSubview(graphicsView, at: 0)
        
        updateViewportSize(graphicsView.drawableSize)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        scene?.isTurnedOn = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        lastFrameTimestamp = CACurrentMediaTime()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        scene?.isTurnedOn = false
    }
    
    private func updateViewportSize(_ size: CGSize) {
        renderingContext.viewportSize = size.float2
        scene?.viewCamera.camera!.aspectRatio = Float(size.width / size.height)
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
        
        let frameTimestamp = CACurrentMediaTime()
        let deltaTime = Float(frameTimestamp - lastFrameTimestamp)
        
        for frameListener in frameListeners {
            frameListener.onFrameUpdate(deltaTime: deltaTime)
        }
        
        renderingContext.renderPassDescriptor = renderPassDescriptor
        
        renderer.render(scene!, context: renderingContext)
        
        if let drawable = graphicsView.currentDrawable {
            drawable.present()
        }
        
        lastFrameTimestamp = frameTimestamp
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
            guard isVisible else { return }
            updateViewportSize(graphicsView.drawableSize)
        }
    }
    
    func createFrameUpdater() -> GraphicsViewFrameUpdater {
        GraphicsViewFrameUpdater(graphicsViewController: self)
    }
    
    func addFrameListener(_ frameListener: GraphicsViewFrameListener) {
        frameListeners.append(frameListener)
    }
    
    func removeFrameListener(_ frameListener: GraphicsViewFrameListener) {
        if let index = frameListeners.firstIndex(where: {$0 === frameListener}) {
            frameListeners.remove(at: index)
        }
    }
    
    private var frameListeners = [GraphicsViewFrameListener]()
    
    let renderer = Renderer.make()!
    private(set) var graphicsView: MTKView! = nil
    private let renderingContext = RenderingContext()
    private var lastFrameTimestamp: TimeInterval = 0.0
}
