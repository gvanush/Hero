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
        addGestureRecognizers()
        
//        scene.viewCamera.projection = Projection_ortographic
        scene.viewCamera.orthographicScale = 70.0;
        scene.viewCamera.fovy = Float.pi * 0.3
        
        viewCameraSphericalCoord.radius = 100.0
        viewCameraSphericalCoord.longitude = Float.pi
        viewCameraSphericalCoord.latitude = 0.5 * Float.pi
        scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
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
            if i == 0 {
                layer.position = simd_float3.zero
            } else {
                let positionRange = Float(-70.0)...Float(70.0)
                layer.position = simd_float3(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: Float.random(in: 0.0...500.0))
            }
            scene.addLayer(layer)
        }
    }
    
    func addGestureRecognizers() {
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        panGR.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGR)
        
        let twoFingerPanGR = UIPanGestureRecognizer(target: self, action: #selector(onTwoFingerPan))
        twoFingerPanGR.minimumNumberOfTouches = 2
        twoFingerPanGR.maximumNumberOfTouches = 2
        sceneView.addGestureRecognizer(twoFingerPanGR)
    }
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        
        switch panGR.state {
        case .began:
            gesturePrevLoc = panGR.location(in: sceneView)
        case .changed:
            
            let loc = panGR.location(in: sceneView)
            let delta = 0.005 * SIMD2<Float>(Float(loc.x - gesturePrevLoc.x), Float(loc.y - gesturePrevLoc.y))
            viewCameraSphericalCoord.longitude += delta.x
            viewCameraSphericalCoord.latitude -= delta.y
            scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
            scene.viewCamera.look(at: viewCameraSphericalCoord.center, up: SIMD3<Float>.up)
            
            gesturePrevLoc = loc
        default:
            break
        }
    }
    
    @objc func onTwoFingerPan(panGR: UIPanGestureRecognizer) {
        
        switch panGR.state {
        case .began:
            gesturePrevLoc = panGR.location(ofTouch: 0, in: sceneView)
        case .changed:
            let loc = panGR.location(ofTouch: 0, in: sceneView)
            
            if panGR.numberOfTouches == 2 {
                let prevScenePos = scene.viewCamera.convert(toWorld: SIMD4<Float>(Float(gesturePrevLoc.x), Float(gesturePrevLoc.y), 0.0, 1.0), fromViewportWith: viewportSize())
                let scenePos = scene.viewCamera.convert(toWorld: SIMD4<Float>(Float(loc.x), Float(loc.y), 0.0, 1.0), fromViewportWith: viewportSize())
                let delta = scenePos - prevScenePos
                viewCameraSphericalCoord.center -= SIMD3<Float>(delta.x, delta.y, delta.z)
                scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
            }
            
            gesturePrevLoc = loc
            
        default:
            break
        }
        
    }
    
    func viewportSize() ->Size2 {
        Size2(width: Float(self.sceneView.bounds.size.width), height: Float(self.sceneView.bounds.size.height))
    }
    
    var sceneView: MTKView!
    var scene: HeroScene
    var gesturePrevLoc = CGPoint.zero
    var viewCameraSphericalCoord = SphericalCoord()
    var renderingContext = RenderingContext()
}
