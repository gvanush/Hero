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
        
        addLayers()
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
    
    func addLayers() {
        let sampleImageCount = 5
        let textureLoader = MTKTextureLoader(device: RenderingContext.device())
        
        for i in 0..<sampleImageCount {
            let texture = try! textureLoader.newTexture(name: "sample_image_\(i)", scaleFactor: 1.0, bundle: nil, options: nil)
            
            let sizeRange = Float(10.0)...Float(100.0)
            let width = Float.random(in: sizeRange)
            let height = Float.random(in: sizeRange)
            
            let size = min(width, height) / 2.0
            let texRatio = Float(texture.width) / Float(texture.height)
            
            let layer = Layer()
            layer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
            layer.texture = texture
            let positionRange = Float(-100.0)...Float(100.0)
            layer.position = simd_float3(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: 0.0)
            scene.addLayer(layer)
        }
    }
    
    var sceneView: MTKView!
    var scene: HeroScene
    var renderingContext = RenderingContext()
}
