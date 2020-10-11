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
        scene.viewCamera.orthographicScale = 70.0
        scene.viewCamera.fovy = Float.pi / 3.0
        
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
            let texRatio = Float(texture.width) / Float(texture.height)
            
            let layer = Layer()
            layer.texture = texture
            if i == 0 {
                let size = Float(30.0)
                layer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                layer.position = simd_float3.zero
            } else {
                
                let sizeRange = Float(10.0)...Float(100.0)
                let width = Float.random(in: sizeRange)
                let height = Float.random(in: sizeRange)
                
                let size = min(width, height) / 2.0
                
                let positionRange = Float(-70.0)...Float(70.0)
                layer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                layer.position = simd_float3(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: Float.random(in: 0.0...300.0))
            }
            scene.addLayer(layer)
        }
    }
    
    func addGestureRecognizers() {
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        panGR.isEnabled = false
        panGR.delegate = self
        panGR.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGR)
        
        let twoFingerPanGR = UIPanGestureRecognizer(target: self, action: #selector(onTwoFingerPan))
        twoFingerPanGR.isEnabled = false
        twoFingerPanGR.delegate = self
        twoFingerPanGR.minimumNumberOfTouches = 2
        twoFingerPanGR.maximumNumberOfTouches = 2
        sceneView.addGestureRecognizer(twoFingerPanGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(onPinch))
        pinchGR.delegate = self
        sceneView.addGestureRecognizer(pinchGR)
        
    }
    
    @objc func onPinch(pinchGR: UIPinchGestureRecognizer) {
        
        guard pinchGR.numberOfTouches == 2 else {
            pinchGR.cancel()
            return
        }
        
        switch pinchGR.state {
        case .began:
            let loc0 = pinchGR.location(ofTouch: 0, in: self.sceneView)
            let loc1 = pinchGR.location(ofTouch: 1, in: self.sceneView)
            let dist = length(SIMD2<Float>(Float(loc0.x - loc1.x), Float(loc0.y - loc1.y)))
            prevDist = dist
        case .changed:
        
            let loc0 = pinchGR.location(ofTouch: 0, in: self.sceneView)
            let loc1 = pinchGR.location(ofTouch: 1, in: self.sceneView)
            let dist = length(SIMD2<Float>(Float(loc0.x - loc1.x), Float(loc0.y - loc1.y)))
            
            let centerViewportPos = scene.viewCamera.convertWorldToViewport(viewCameraSphericalCoord.center, viewportSize: viewportSize())
            
            let scenePos = scene.viewCamera.convertViewportToWorld(centerViewportPos + SIMD3<Float>.up * 0.5 * (dist - prevDist), viewportSize: viewportSize())
            
            let angle = 0.5 * scene.viewCamera.fovy * (dist / viewportSize().y)
            let radiusDelta = length(scenePos - viewCameraSphericalCoord.center) / tanf(angle)
            viewCameraSphericalCoord.radius += (dist > prevDist ? -radiusDelta : radiusDelta)
            
            scene.viewCamera.position = viewCameraSphericalCoord.getPosition()

            prevDist = dist
            
        default:
            
            break
        }
    }
    
    private var prevDist: Float = 0.0
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        
        switch panGR.state {
        case .began:
            let loc = panGR.location(in: sceneView)
            gesturePrevPos.x = Float(loc.x)
            gesturePrevPos.y = Float(loc.y)
        case .changed:
            
            let loc = panGR.location(in: sceneView)
            let pos = SIMD2<Float>(Float(loc.x), Float(loc.y))
            let angleDelta = Float.pi * (pos - gesturePrevPos) / viewportSize().min()
            viewCameraSphericalCoord.longitude += angleDelta.x
            viewCameraSphericalCoord.latitude -= angleDelta.y
            scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
            scene.viewCamera.look(at: viewCameraSphericalCoord.center, up: (sinf(viewCameraSphericalCoord.latitude) >= 0.0 ? SIMD3<Float>.up : SIMD3<Float>.down))
            
            gesturePrevPos = pos
        default:
            break
        }
    }
    
    @objc func onTwoFingerPan(panGR: UIPanGestureRecognizer) {
        
        let averagePosition = { () -> SIMD2<Float> in
            let loc0 = panGR.location(ofTouch: 0, in: self.sceneView)
            let loc1 = panGR.location(ofTouch: 1, in: self.sceneView)
            return 0.5 * SIMD2<Float>(Float(loc0.x + loc1.x), Float(loc0.y + loc1.y))
        }
        
        struct Statics {
            static var shouldResetPos = false
        }
        
        switch panGR.state {
        case .began:
            gesturePrevPos = averagePosition()
        case .changed:
        
            guard panGR.numberOfTouches == 2 else {
                Statics.shouldResetPos = true
                return
            }
                
            let pos = averagePosition()
            
            if Statics.shouldResetPos {
                gesturePrevPos = pos
                Statics.shouldResetPos = false
                return
            }
            
            let ndcZ = scene.viewCamera.convertWorldToNDC(viewCameraSphericalCoord.center).z
            
            let prevScenePos = scene.viewCamera.convertViewportToWorld(SIMD3<Float>(gesturePrevPos, ndcZ), viewportSize: viewportSize())
            let scenePos = scene.viewCamera.convertViewportToWorld(SIMD3<Float>(pos, ndcZ), viewportSize: viewportSize())
            
            viewCameraSphericalCoord.center += (prevScenePos - scenePos)
            scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
            
            gesturePrevPos = pos
            
        default:
            break
        }
        
    }
    
    func viewportSize() -> SIMD2<Float> {
        SIMD2<Float>(Float(self.sceneView.bounds.size.width), Float(self.sceneView.bounds.size.height))
    }
    
    var sceneView: MTKView!
    var scene: HeroScene
    var panGR: UIPanGestureRecognizer!
    var gesturePrevPos = SIMD2<Float>.zero
    var viewCameraSphericalCoord = SphericalCoord()
    var renderingContext = RenderingContext()
}


extension HeroSceneViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if panGR === gestureRecognizer || panGR === otherGestureRecognizer {
            return false
        }
        return true
    }
}
