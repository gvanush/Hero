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
        sceneView.depthStencilPixelFormat = RenderingContext.depthPixelFormat()
        sceneView.clearColor = MTLClearColor(red: 0.2, green: 0.2, blue: 0.2, alpha: 1.0)
        sceneView.autoResizeDrawable = true
//        sceneView.sampleCount = 2
        sceneView.delegate = self
        view.addSubview(sceneView)
        
        addLayers()
        addGestureRecognizers()
        
//        scene.viewCamera.projection = Projection_ortographic
//        scene.viewCamera.near = 0.1
        scene.viewCamera.orthographicScale = 70.0
        scene.viewCamera.fovy = Float.pi / 3.0
        
        let axisHalfLength: Float = 100.0
        let axisThickness: Float = 4.0
        let xAxis = Line(point1: SIMD3<Float>(-axisHalfLength, 0.0, 0.0), point2: SIMD3<Float>(axisHalfLength, 0.0, 0.0), thickness: axisThickness, color: SIMD4<Float>.red)
        scene.add(xAxis)
        
        let zAxis = Line(point1: SIMD3<Float>(0.0, 0.0, -axisHalfLength), point2: SIMD3<Float>(0.0, 0.0, axisHalfLength), thickness: axisThickness, color: SIMD4<Float>.blue)
        scene.add(zAxis)
        
        viewCameraSphericalCoord.radius = 100.0
        viewCameraSphericalCoord.longitude = Float.pi
        viewCameraSphericalCoord.latitude = 0.5 * Float.pi
        scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
        
        updateViewportSize(SIMD2<Float>(x: Float(sceneView.drawableSize.width), y: Float(sceneView.drawableSize.height)))
    }
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        updateViewportSize(SIMD2<Float>(x: Float(size.width), y: Float(size.height)))
    }
    
    func updateViewportSize(_ size: SIMD2<Float>) {
        renderingContext.viewportSize = size
        scene.viewCamera.aspectRatio = size.x / size.y
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
            scene.add(layer)
        }
    }
    
    func addGestureRecognizers() {
        
        panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        panGR.delegate = self
        panGR.maximumNumberOfTouches = 1
        sceneView.addGestureRecognizer(panGR)
        
        let twoFingerPanGR = UIPanGestureRecognizer(target: self, action: #selector(onTwoFingerPan))
        twoFingerPanGR.delegate = self
        twoFingerPanGR.minimumNumberOfTouches = 2
        twoFingerPanGR.maximumNumberOfTouches = 2
        sceneView.addGestureRecognizer(twoFingerPanGR)
        
        let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(onPinch))
//        pinchGR.isEnabled = false
        pinchGR.delegate = self
        sceneView.addGestureRecognizer(pinchGR)
        
    }
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        
        switch panGR.state {
        case .began:
            let loc = panGR.location(in: sceneView)
            gesturePrevPos.x = Float(loc.x)
            gesturePrevPos.y = Float(loc.y)
        case .changed:
            
            let loc = panGR.location(in: sceneView)
            let pos = SIMD2<Float>(Float(loc.x), Float(loc.y))
            let angleDelta = 2.0 * Float.pi * (pos - gesturePrevPos) / sceneViewSize().min()
            
            viewCameraSphericalCoord.latitude -= angleDelta.y
            
            let isInFrontOfSphere = sinf(viewCameraSphericalCoord.latitude) >= 0.0
            viewCameraSphericalCoord.longitude += (isInFrontOfSphere ? angleDelta.x : -angleDelta.x)
            
            scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
            scene.viewCamera.look(at: viewCameraSphericalCoord.center, up: (isInFrontOfSphere ? SIMD3<Float>.up : SIMD3<Float>.down))
            
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
        
        switch panGR.state {
        case .began:
            guard panGR.numberOfTouches == 2 else {
                panGR.cancel()
                return
            }
            gesturePrevPos = averagePosition()
        case .changed:
        
            guard panGR.numberOfTouches == 2 else {
                shouldResetTwoFingerPan = true
                return
            }
                
            let pos = averagePosition()
            
            if shouldResetTwoFingerPan {
                gesturePrevPos = pos
                shouldResetTwoFingerPan = false
                return
            }
            
            let ndcZ = scene.viewCamera.convertWorldToNDC(viewCameraSphericalCoord.center).z
            
            let prevScenePos = scene.viewCamera.convertViewportToWorld(SIMD3<Float>(gesturePrevPos, ndcZ), viewportSize: sceneViewSize())
            let scenePos = scene.viewCamera.convertViewportToWorld(SIMD3<Float>(pos, ndcZ), viewportSize: sceneViewSize())
            
            viewCameraSphericalCoord.center += (prevScenePos - scenePos)
            scene.viewCamera.position = viewCameraSphericalCoord.getPosition()
            
            gesturePrevPos = pos
            
        default:
            break
        }
        
    }
    
    @objc func onPinch(pinchGR: UIPinchGestureRecognizer) {
        
        let fingerDistance = { () -> Float in
            let loc0 = pinchGR.location(ofTouch: 0, in: self.sceneView)
            let loc1 = pinchGR.location(ofTouch: 1, in: self.sceneView)
            return length(SIMD2<Float>(Float(loc0.x - loc1.x), Float(loc0.y - loc1.y)))
        }
        
        switch pinchGR.state {
        case .began:
            guard pinchGR.numberOfTouches == 2 else {
                pinchGR.cancel()
                return
            }
            
            switch scene.viewCamera.projection {
            case Projection_perspective:
                pinchPrevFingerDist = fingerDistance()
            case Projection_ortographic:
                initialOrtohraphicScale = scene.viewCamera.orthographicScale
            default:
                assertionFailure()
                break
            }
            
        case .changed:
            
            switch scene.viewCamera.projection {
            case Projection_perspective:
                
                guard pinchGR.numberOfTouches == 2 else {
                    shouldResetPinch = true
                    return
                }
            
                let dist = fingerDistance()
                
                if shouldResetPinch {
                    pinchPrevFingerDist = dist
                    shouldResetPinch = false
                    return
                }
                
                let centerViewportPos = scene.viewCamera.convertWorldToViewport(viewCameraSphericalCoord.center, viewportSize: sceneViewSize())
                var scenePos = scene.viewCamera.convertViewportToWorld(centerViewportPos + SIMD3<Float>.up * 0.5 * (dist - pinchPrevFingerDist), viewportSize: sceneViewSize())
                
                // NOTE: This is needed, because coverting from world to viewport and back gives low precision z value.
                // It is becasue of uneven distribution of world z into ndc z, especially far objects.
                // Alternative could be to make near plane larger but that limits zooming since object will be clipped
                scenePos.z = viewCameraSphericalCoord.center.z
                
                let angle = 0.5 * scene.viewCamera.fovy * (dist / sceneViewSize().y)
                let radiusDelta = length(scenePos - viewCameraSphericalCoord.center) / tanf(angle)
                
                viewCameraSphericalCoord.radius = max(viewCameraSphericalCoord.radius + (dist > pinchPrevFingerDist ? -radiusDelta : radiusDelta), 0.01)
                
                scene.viewCamera.position = viewCameraSphericalCoord.getPosition()

                pinchPrevFingerDist = dist
                
            case Projection_ortographic:
                
                scene.viewCamera.orthographicScale = max(initialOrtohraphicScale / Float(pinchGR.scale), 0.01)
                
            default:
                assertionFailure()
                break
            }
            
        default:
            
            break
        }
    }
    
    func sceneViewSize() -> SIMD2<Float> {
        SIMD2<Float>(Float(self.sceneView.bounds.size.width), Float(self.sceneView.bounds.size.height))
    }
    
    private var sceneView: MTKView!
    private var scene: HeroScene
    private var panGR: UIPanGestureRecognizer!
    private var gesturePrevPos = SIMD2<Float>.zero
    private var shouldResetTwoFingerPan = false
    private var shouldResetPinch = false
    private var pinchPrevFingerDist: Float = 0.0
    private var initialOrtohraphicScale: Float = 1.0
    private var viewCameraSphericalCoord = SphericalCoord()
    private var renderingContext = RenderingContext()
}


extension HeroSceneViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if panGR === gestureRecognizer || panGR === otherGestureRecognizer {
            return false
        }
        return true
    }
}
