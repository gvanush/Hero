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
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        panGR.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGR)
        
        let twoFingerPanGR = UIPanGestureRecognizer(target: self, action: #selector(onTwoFingerPan))
        twoFingerPanGR.delegate = self
        twoFingerPanGR.minimumNumberOfTouches = 2
        twoFingerPanGR.maximumNumberOfTouches = 2
        sceneView.addGestureRecognizer(twoFingerPanGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(onPinch))
        pinchGR.delegate = self
        sceneView.addGestureRecognizer(pinchGR)
        
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(onTap))
        sceneView.addGestureRecognizer(tapGR)
    }
    
    @objc func onTap(tapGR: UIRotationGestureRecognizer) {
        if tapGR.state == .recognized {
        }
    }
    
    @objc func onPinch(pinchGR: UIPinchGestureRecognizer) {
//        print("inPinch: \(pinchGR.scale)")
    }
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        
        switch panGR.state {
        case .began:
            gesturePrevLoc = panGR.location(in: sceneView)
        case .changed:
            
            let loc = panGR.location(in: sceneView)
            let angleDelta = Float.pi * SIMD2<Float>(Float(loc.x - gesturePrevLoc.x), Float(loc.y - gesturePrevLoc.y)) / viewportSize().min()
            viewCameraSphericalCoord.longitude += angleDelta.x
            viewCameraSphericalCoord.latitude -= angleDelta.y
            scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
            scene.viewCamera.look(at: viewCameraSphericalCoord.center, up: (sinf(viewCameraSphericalCoord.latitude) >= 0.0 ? SIMD3<Float>.up : SIMD3<Float>.down))
            
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
                
                let ndcZ = scene.viewCamera.convertWorldToNDC(viewCameraSphericalCoord.center).z
                
                let prevScenePos = scene.viewCamera.convertViewportToWorld(SIMD3<Float>(Float(gesturePrevLoc.x), Float(gesturePrevLoc.y), ndcZ), viewportSize: viewportSize())
                let scenePos = scene.viewCamera.convertViewportToWorld(SIMD3<Float>(Float(loc.x), Float(loc.y), ndcZ), viewportSize: viewportSize())
                
                viewCameraSphericalCoord.center += (prevScenePos - scenePos)
                scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
            }
            gesturePrevLoc = loc
            
        default:
            break
        }
        
    }
    
    func viewportSize() -> SIMD2<Float> {
        SIMD2<Float>(Float(self.sceneView.bounds.size.width), Float(self.sceneView.bounds.size.height))
    }
    
    var sceneView: MTKView!
    var scene: HeroScene
    var gesturePrevLoc = CGPoint.zero
    var viewCameraSphericalCoord = SphericalCoord()
    var renderingContext = RenderingContext()
}


extension HeroSceneViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        true
    }
}
