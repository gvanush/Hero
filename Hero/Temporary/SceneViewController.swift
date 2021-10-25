//
//  SceneViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/18/21.
//

import UIKit
import PhotosUI
import MobileCoreServices

class SceneViewController: GraphicsViewController, UIGestureRecognizerDelegate {
    
    init(scene: Scene, viewCameraSphericalCoord: SphericalCoord) {
        self.viewCameraSphericalCoord = viewCameraSphericalCoord
        super.init(scene: scene)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setupGestures()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            graphicsView.clearColor = UIColor.sceneBgrColor.mtlClearColor
        }
    }
    
    // MARK: Scene interaction
    public var isNavigating = false {
        didSet {
            NotificationCenter.default.post(name: .sceneNavigationStateDidChange, object: self, userInfo: ["value": isNavigating])
        }
    }
    
    private var twoFingerPanGestureRecognizer: UIPanGestureRecognizer!
    private var pinchGestureRecognizer: UIPinchGestureRecognizer!
    
    private func setupGestures() {
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(onTap))
        graphicsView.addGestureRecognizer(tapGR)
        
        let panGR = UIPanGestureRecognizer(target: self, action: #selector(onPan))
        panGR.delegate = self
        panGR.maximumNumberOfTouches = 1
        graphicsView.addGestureRecognizer(panGR)
        
        twoFingerPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(onTwoFingerPan))
        twoFingerPanGestureRecognizer.delegate = self
        twoFingerPanGestureRecognizer.minimumNumberOfTouches = 2
        twoFingerPanGestureRecognizer.maximumNumberOfTouches = 2
        graphicsView.addGestureRecognizer(twoFingerPanGestureRecognizer)
        
        pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(onPinch))
        pinchGestureRecognizer.delegate = self
        graphicsView.addGestureRecognizer(pinchGestureRecognizer)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if (gestureRecognizer === twoFingerPanGestureRecognizer && otherGestureRecognizer === pinchGestureRecognizer) || (otherGestureRecognizer === twoFingerPanGestureRecognizer && gestureRecognizer === pinchGestureRecognizer) {
            return true
        }
        return false
    }
    
    @objc func onTap(tapGR: UITapGestureRecognizer) {
        guard tapGR.state == .recognized else {
            return
        }
        
        let pos = tapGR.location(in: graphicsView).float2
        let scenePos = scene.viewCamera.camera!.convertViewportToWorld(SIMD3<Float>(pos, 1.0), viewportSize: graphicsView.bounds.size.float2)
        
        if let selected = scene.rayCast(makeRay(scene.viewCamera.transform!.position, scenePos - scene.viewCamera.transform!.position)) {
            scene.selectedObject = selected
        } else {
            scene.selectedObject = nil
        }
    }
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        switch panGR.state {
        case .began:
            isNavigating = true
            gesturePrevPos = panGR.location(in: graphicsView).float2
            
        case .changed:
            
            let pos = panGR.location(in: graphicsView).float2
            let angleDelta = 2.0 * Float.pi * (pos - gesturePrevPos) / graphicsView.bounds.size.float2.min()
            
            viewCameraSphericalCoord.latitude -= angleDelta.y
            
            let isInFrontOfSphere = sinf(viewCameraSphericalCoord.latitude) >= 0.0
            viewCameraSphericalCoord.longitude += (isInFrontOfSphere ? angleDelta.x : -angleDelta.x)
            
            scene.viewCamera.transform!.position = viewCameraSphericalCoord.getPosition()
            scene.viewCamera.camera!.look(at: viewCameraSphericalCoord.center, up: (isInFrontOfSphere ? SIMD3<Float>.up : SIMD3<Float>.down))
            
            gesturePrevPos = pos
            
        default:
            isNavigating = false
        }
    }
    
    @objc func onTwoFingerPan(panGR: UIPanGestureRecognizer) {
        let averagePosition = { () -> SIMD2<Float> in
            let loc0 = panGR.location(ofTouch: 0, in: self.graphicsView)
            let loc1 = panGR.location(ofTouch: 1, in: self.graphicsView)
            return 0.5 * SIMD2<Float>(Float(loc0.x + loc1.x), Float(loc0.y + loc1.y))
        }
        
        switch panGR.state {
        case .began:
            guard panGR.numberOfTouches == 2 else {
                panGR.cancel()
                return
            }
            gesturePrevPos = averagePosition()
            isNavigating = true
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
            
            let ndcZ = scene.viewCamera.camera!.convertWorldToNDC(viewCameraSphericalCoord.center).z
            
            let prevScenePos = scene.viewCamera.camera!.convertViewportToWorld(SIMD3<Float>(gesturePrevPos, ndcZ), viewportSize: graphicsView.bounds.size.float2)
            let scenePos = scene.viewCamera.camera!.convertViewportToWorld(SIMD3<Float>(pos, ndcZ), viewportSize: graphicsView.bounds.size.float2)
            
            viewCameraSphericalCoord.center += (prevScenePos - scenePos)
            scene.viewCamera.transform!.position = viewCameraSphericalCoord.getPosition()
            
            gesturePrevPos = pos
            
        default:
            isNavigating = false
        }
    }
    
    @objc func onPinch(pinchGR: UIPinchGestureRecognizer) {
        
        let fingerDistance = { () -> Float in
            let loc0 = pinchGR.location(ofTouch: 0, in: self.graphicsView)
            let loc1 = pinchGR.location(ofTouch: 1, in: self.graphicsView)
            return length(SIMD2<Float>(Float(loc0.x - loc1.x), Float(loc0.y - loc1.y)))
        }
        
        switch pinchGR.state {
        case .began:
            guard pinchGR.numberOfTouches == 2 else {
                pinchGR.cancel()
                return
            }
            
            switch scene.viewCamera.camera!.projection {
            case Projection_perspective:
                pinchPrevFingerDist = fingerDistance()
            case Projection_ortographic:
                initialOrtohraphicScale = scene.viewCamera.camera!.orthographicScale
            default:
                assertionFailure()
                break
            }
            
            isNavigating = true
            
        case .changed:
            
            switch scene.viewCamera.camera!.projection {
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
                
                let centerViewportPos = scene.viewCamera.camera!.convertWorldToViewport(viewCameraSphericalCoord.center, viewportSize: graphicsView.bounds.size.float2)
                var scenePos = scene.viewCamera.camera!.convertViewportToWorld(centerViewportPos + SIMD3<Float>.up * 0.5 * (dist - pinchPrevFingerDist), viewportSize: graphicsView.bounds.size.float2)
                
                // NOTE: This is needed, because coverting from world to viewport and back gives low precision z value.
                // It is becasue of uneven distribution of world z into ndc z, especially far objects.
                // Alternative could be to make near plane larger but that limits zooming since object will be clipped
                scenePos.z = viewCameraSphericalCoord.center.z
                
                let angle = 0.5 * scene.viewCamera.camera!.fovy * (dist / graphicsView.bounds.size.float2.y)
                let radiusDelta = length(scenePos - viewCameraSphericalCoord.center) / tanf(angle)
                
                viewCameraSphericalCoord.radius = max(viewCameraSphericalCoord.radius + (dist > pinchPrevFingerDist ? -radiusDelta : radiusDelta), 0.01)
                
                scene.viewCamera.transform!.position = viewCameraSphericalCoord.getPosition()

                pinchPrevFingerDist = dist
                
            case Projection_ortographic:
                
                scene.viewCamera.camera!.orthographicScale = max(initialOrtohraphicScale / Float(pinchGR.scale), 0.01)
                
            default:
                assertionFailure()
                break
            }
            
        default:
            isNavigating = false
        }
        
    }
    
    private var gesturePrevPos = SIMD2<Float>.zero
    private var viewCameraSphericalCoord: SphericalCoord
    private var shouldResetTwoFingerPan = false
    private var pinchPrevFingerDist: Float = 0.0
    private var shouldResetPinch = false
    private var initialOrtohraphicScale: Float = 1.0
}

