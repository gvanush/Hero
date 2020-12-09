//
//  SceneNavigationController.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11/18/20.
//

import Foundation
import UIKit
import SwiftUI

class SceneNavigationController {
    let scene: Hero.Scene
    let sceneView: MTKView
    @Binding var isNavigating: Bool
    
    init(scene: Hero.Scene, sceneView: MTKView, isNavigating: Binding<Bool>) {
        self.scene = scene
        self.sceneView = sceneView
        _isNavigating = isNavigating
        
        viewCameraSphericalCoord.radius = 100.0
        viewCameraSphericalCoord.longitude = Float.pi
        viewCameraSphericalCoord.latitude = 0.5 * Float.pi
        scene.viewCamera.transform.position = viewCameraSphericalCoord.getPosition()
    }
    
    @objc func onTap(tapGR: UITapGestureRecognizer) {
        guard tapGR.state == .recognized else {
            return
        }
        
        let pos = SIMD2<Float>(from: tapGR.location(in: sceneView))
        let scenePos = scene.viewCamera.convertViewportToWorld(SIMD3<Float>(pos, 1.0), viewportSize: sceneViewSize())
        
        if let selected = scene.rayCast(makeRay(scene.viewCamera.transform.position, scenePos - scene.viewCamera.transform.position)) {
            print("Selected: \(selected.name)")
            scene.selectedObject = selected
//            sceneView.clearColor = UIColor.red.mtlClearColor
//            selected.position.y = 30.0;
        } else {
            print("None")
            scene.selectedObject = nil
        }
    }
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        switch panGR.state {
        case .began:
            withAnimation {
                isNavigating = true
            }
            
            gesturePrevPos = SIMD2<Float>(from: panGR.location(in: sceneView))
            
        case .changed:
            
            let pos = SIMD2<Float>(from: panGR.location(in: sceneView))
            let angleDelta = 2.0 * Float.pi * (pos - gesturePrevPos) / sceneViewSize().min()
            
            viewCameraSphericalCoord.latitude -= angleDelta.y
            
            let isInFrontOfSphere = sinf(viewCameraSphericalCoord.latitude) >= 0.0
            viewCameraSphericalCoord.longitude += (isInFrontOfSphere ? angleDelta.x : -angleDelta.x)
            
            scene.viewCamera.transform.position = viewCameraSphericalCoord.getPosition()
            scene.viewCamera.look(at: viewCameraSphericalCoord.center, up: (isInFrontOfSphere ? SIMD3<Float>.up : SIMD3<Float>.down))
            
            gesturePrevPos = pos
            
        default:
            withAnimation {
                isNavigating = false
            }
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
            withAnimation {
                isNavigating = true
            }
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
            scene.viewCamera.transform.position = viewCameraSphericalCoord.getPosition()
            
            gesturePrevPos = pos
            
        default:
            withAnimation {
                isNavigating = false
            }
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
            withAnimation {
                isNavigating = true
            }
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
                
                scene.viewCamera.transform.position = viewCameraSphericalCoord.getPosition()

                pinchPrevFingerDist = dist
                
            case Projection_ortographic:
                
                scene.viewCamera.orthographicScale = max(initialOrtohraphicScale / Float(pinchGR.scale), 0.01)
                
            default:
                assertionFailure()
                break
            }
            
        default:
            withAnimation {
                isNavigating = false
            }
            break
        }
        
    }
    
    private func sceneViewSize() -> SIMD2<Float> {
        SIMD2<Float>(Float(sceneView.bounds.size.width), Float(sceneView.bounds.size.height))
    }
    
    private var gesturePrevPos = SIMD2<Float>.zero
    private var viewCameraSphericalCoord = SphericalCoord()
    private var pinchPrevFingerDist: Float = 0.0
    private var shouldResetTwoFingerPan = false
    private var shouldResetPinch = false
    private var initialOrtohraphicScale: Float = 1.0
}
