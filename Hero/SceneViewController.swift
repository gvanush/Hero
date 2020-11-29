//
//  SceneViewController.swift
//  Hero
//
//  Created by Vanush Grigoryan on 7/31/20.
//

import UIKit
import MetalKit
import Metal

class SceneViewController: UIViewController {
    
    init(scene: Scene, rootViewModel: RootViewModel) {
        self.scene = scene
        self.rootViewModel = rootViewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var rootViewModel: RootViewModel
    private var sceneView: MTKView!
    private var scene: Scene
    private var panGR: UIPanGestureRecognizer!
    private var gesturePrevPos = SIMD2<Float>.zero
    private var shouldResetTwoFingerPan = false
    private var shouldResetPinch = false
    private var pinchPrevFingerDist: Float = 0.0
    private var initialOrtohraphicScale: Float = 1.0
    private var viewCameraSphericalCoord = SphericalCoord()
    private var renderingContext = RenderingContext()
}
