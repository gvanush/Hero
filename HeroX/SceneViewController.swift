//
//  SceneViewController.swift
//  HeroX
//
//  Created by Vanush Grigoryan on 1/18/21.
//

import UIKit
import PhotosUI
import MobileCoreServices

class SceneViewController: GraphicsViewController, UIGestureRecognizerDelegate, TransformViewControllerDelegate, SlidingViewControllerDelegate, PHPickerViewControllerDelegate {
    
    @IBOutlet weak var selectedObjectName: UILabel!
    @IBOutlet weak var bottomGroupView: UIView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var progressView: UIProgressView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        setupScene()
        setupSlidingViewController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        slidingViewController.inset = view.safeAreaInsets.bottom + toolbar.frame.size.height
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            graphicsView.clearColor = UIColor.sceneBgrColor.mtlClearColor
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        isNavigating
    }
    
    private func setupScene() {
        scene = Scene()
        
        setupCamera()
        setupAxis()
        addImages()
        
        setupGestures()

    }
    
    private func setupCamera() {
        scene!.viewCamera.camera.near = 0.1
        scene!.viewCamera.camera.far = 1000.0
        scene!.viewCamera.camera.fovy = Float.pi / 3.0
        scene!.viewCamera.camera.orthographicScale = 70.0
        
        viewCameraSphericalCoord.radius = 100.0
        viewCameraSphericalCoord.longitude = Float.pi
        viewCameraSphericalCoord.latitude = 0.5 * Float.pi
        scene!.viewCamera.transform.position = viewCameraSphericalCoord.getPosition()
    }
    
    private func setupAxis() {
        let axisHalfLength: Float = 1000.0
        let axisThickness: Float = 5.0
        
        // xAxis
        scene!.makeLine(point1: SIMD3<Float>(-axisHalfLength, 0.0, 0.0), point2: SIMD3<Float>(axisHalfLength, 0.0, 0.0), thickness: axisThickness, color: SIMD4<Float>.red)
        
        // zAxis
        scene!.makeLine(point1: SIMD3<Float>(0.0, 0.0, -axisHalfLength), point2: SIMD3<Float>(0.0, 0.0, axisHalfLength), thickness: axisThickness, color: SIMD4<Float>.blue)
    }
    
    private func addImages() {
        let sampleImageCount = 5
        let textureLoader = MTKTextureLoader(device: RenderingContext.device())
        
        for i in 0..<sampleImageCount {
            let texture = try! textureLoader.newTexture(name: "sample_image_\(i)", scaleFactor: 1.0, bundle: nil, options: nil)
            let texRatio = Float(texture.width) / Float(texture.height)
            
            let imageObject = scene!.makeImage()
            imageObject.textureRenderer.texture = texture
            if i == 0 {
                let size = Float(30.0)
                imageObject.textureRenderer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                imageObject.transform.position = simd_float3(0.0, 0.0, 20.0)
            } else {
                
                let sizeRange = Float(10.0)...Float(100.0)
                let width = Float.random(in: sizeRange)
                let height = Float.random(in: sizeRange)
                
                let size = min(width, height) / 2.0
                
                let positionRange = Float(-70.0)...Float(70.0)
                imageObject.textureRenderer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                imageObject.transform.position = simd_float3(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: Float.random(in: 0.0...300.0))
            }
        }
    }
    
    // MARK: Object creation/deletion
    @IBAction func onAddObjectPressed(_ sender: UIBarButtonItem) {
        let config = PHPickerConfiguration()
//        config.selectionLimit = 2
        let imagePickerController = PHPickerViewController(configuration: config)
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
    
    // MARK: PHPickerViewControllerDelegate
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        guard !results.isEmpty else { return }
        print(results)
        
        let itemProvider = results.first!.itemProvider
        if itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { (image, error) in
                if let error = error {
                    // TODO
                    assertionFailure(error.localizedDescription)
                    return
                }

                let textureLoader = MTKTextureLoader(device: RenderingContext.device())
                let image = image as! UIImage
                print("orientation: \(image.imageOrientation.rawValue)")
                let texture = try! textureLoader.newTexture(cgImage: image.cgImage!, options: nil)
                
                DispatchQueue.main.async {
                    let imageObject = self.scene!.makeImage()
                    imageObject.textureRenderer.texture = texture
                    imageObject.textureRenderer.textureOrientation = image.textureOrientation
                    
                    let textureSize = imageObject.textureRenderer.textureSize
                    print("widt: \(textureSize.x), height: \(textureSize.y)")
                    let texRatio = Float(textureSize.x) / Float(textureSize.y)
                    let size: Float = 50.0
                    imageObject.textureRenderer.size = (texRatio > 1.0 ? simd_float2(x: size, y: size / texRatio) : simd_float2(x: size * texRatio, y: size))
                }
            }
        } else {
            // TODO
        }
    }
    
    // MARK: Selected object
    var selectedObject: SceneObject? {
        willSet {
            if let newSelectedObject = newValue {
                selectedObjectName.text = newSelectedObject.name
                let transformVC = storyboard!.instantiateViewController(withIdentifier: "Transform") as! TransformViewController
                transformVC.delegate = self
                transformVC.transform = newSelectedObject.transform
                transformVC.graphicsViewFrameUpdater = createFrameUpdater()
                transformVC.view.backgroundColor = .clear
                slidingViewController.bodyViewController = transformVC
                slidingViewController.view.isHidden = false
            } else {
                selectedObjectName.text = nil
                slidingViewController.bodyViewController = nil
                slidingViewController.view.isHidden = true
            }
        }
    }
    
    private var slidingViewController: SlidingViewController!
    
    private func setupSlidingViewController() {
        slidingViewController = SlidingViewController()
        slidingViewController.delegate = self
        slidingViewController.backgroundView = UIVisualEffectView(effect: UIBlurEffect(style: .systemThinMaterial))
        slidingViewController.state = .closed
        
        installViewController(slidingViewController) { slidingView in
            slidingView.frame = bottomGroupView.bounds
            slidingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            bottomGroupView.insertSubview(slidingView, belowSubview: toolbar)
        }
        
        let nib = UINib(nibName: "ObjectToolbar", bundle: nil)
        let content = nib.instantiate(withOwner: self, options: nil)
        
        slidingViewController.headerHeight = 65.0
        slidingViewController.headerView = (content.first as! UIView)
        selectedObjectName.text = nil
        
        slidingViewController.view.isHidden = true
    }
    
    // MARK: SlidingViewControllerDelegate
    func slidingViewController(_ slidingViewController: SlidingViewController, willChangeState newState: SlidingViewState) {
        switch newState {
        case .sliding, .open:
            UIView.animate(withDuration: 0.3) {
                self.toolbar.alpha = 0.0
                self.navigationBar.alpha = 0.0
            }
        case .closed:
            UIView.animate(withDuration: 0.3) {
                self.toolbar.alpha = 1.0
                self.navigationBar.alpha = 1.0
            }
        }
    }
    
    // MARK: TransformViewControllerDelegate
    func transformViewController(_ transformViewController: TransformViewController, didBeginContinuousEditingOnNumberField numberField: NumberField) {
        
        assert(retainedNumberFieldRecords[numberField] == nil)
        
        let frame = view.convert(numberField.frame, from: numberField.superview)
        transformViewController.releaseNumberField(numberField)
        view.addSubview(numberField)
        
        let constraints = [
            numberField.centerYAnchor.constraint(equalTo: view.topAnchor, constant: frame.center.y),
            numberField.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: frame.center.x - view.bounds.center.x),
            numberField.widthAnchor.constraint(equalTo: view.widthAnchor, constant: frame.size.width - view.bounds.size.width),
        ]
        NSLayoutConstraint.activate(constraints)
        view.layoutIfNeeded()
        
        let finalCenterY = numberField.continuousEditingGestureRecognizer.location(in: view).y - numberFieldYOffsetToFinger
        constraints.first!.constant = finalCenterY
        constraints[1].constant = 0.0
        constraints.last!.constant = 0.0
        
        retainedNumberFieldRecords[numberField] = RetainedNumberFieldRecord(constraints: constraints, frame: frame, backgroundView: numberField.backgroundView)
        
        UIView.animate(withDuration: 1.0, delay: 0.0, usingSpringWithDamping: 0.65, initialSpringVelocity: 0.0, options: .curveEaseInOut) {
            self.view.layoutIfNeeded()
        }
        
        numberField.setBackgroundView(UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterial)), animated: true)
        
        UIView.animate(withDuration: 0.3) {
            self.slidingViewController.view.alpha = 0.0
        }
        
        numberField.continuousEditingGestureRecognizer.addTarget(self, action: #selector(onNumberFieldCotinuousGesture(_:)))
        
    }
    
    func transformViewController(_ transformViewController: TransformViewController, didEndContinuousEditingOnNumberField numberField: NumberField) {

        let record = retainedNumberFieldRecords.removeValue(forKey: numberField)!
        
        let initialCenter = record.frame.center
        let initialWidth = record.frame.size.width
        record.constraints.first!.constant = initialCenter.y
        record.constraints[1].constant = initialCenter.x - view.bounds.midX
        record.constraints.last!.constant = initialWidth - view.bounds.size.width

        numberField.setBackgroundView(record.backgroundView, animated: true)
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
            self.slidingViewController.view.alpha = 1.0
        } completion: { _ in
            NSLayoutConstraint.deactivate(record.constraints)
            transformViewController.retainNumberField(numberField)
        }
        
        numberField.continuousEditingGestureRecognizer.removeTarget(self, action: nil)
        
    }
    
    @objc func onNumberFieldCotinuousGesture(_ panGR: UIPanGestureRecognizer) {
        guard panGR.state == .changed else { return }
        
        let record = retainedNumberFieldRecords[panGR.view as! NumberField]!
        record.constraints.first!.constant = panGR.location(in: view).y - numberFieldYOffsetToFinger
    }
    
    struct RetainedNumberFieldRecord {
        let constraints: [NSLayoutConstraint]
        let frame: CGRect
        let backgroundView: UIView?
    }
    
    private var retainedNumberFieldRecords = [NumberField : RetainedNumberFieldRecord]()
    private let numberFieldYOffsetToFinger: CGFloat = 70.0
    
    // MARK: Scene interaction
    public var isNavigating = false {
        willSet {
            UIView.animate(withDuration: 0.3) {
                self.bottomGroupView.alpha = (newValue ? 0.0 : 1.0)
                self.navigationBar.alpha = (newValue ? 0.0 : 1.0)
            }
        }
        didSet {
            UIView.animate(withDuration: TimeInterval(UINavigationController.hideShowBarDuration)) {
                self.setNeedsStatusBarAppearanceUpdate()
            }
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
        
        let pos = SIMD2<Float>(from: tapGR.location(in: graphicsView))
        let scenePos = scene!.viewCamera.camera.convertViewportToWorld(SIMD3<Float>(pos, 1.0), viewportSize: graphicsView.bounds.size.simd2)
        
        if let selected = scene!.rayCast(makeRay(scene!.viewCamera.transform.position, scenePos - scene!.viewCamera.transform.position)) {
            scene!.selectedObject = selected
            selectedObject = selected
        } else {
            scene!.selectedObject = nil
            selectedObject = nil
        }
    }
    
    @objc func onPan(panGR: UIPanGestureRecognizer) {
        switch panGR.state {
        case .began:
            isNavigating = true
            gesturePrevPos = SIMD2<Float>(from: panGR.location(in: graphicsView))
            
        case .changed:
            
            let pos = SIMD2<Float>(from: panGR.location(in: graphicsView))
            let angleDelta = 2.0 * Float.pi * (pos - gesturePrevPos) / graphicsView.bounds.size.simd2.min()
            
            viewCameraSphericalCoord.latitude -= angleDelta.y
            
            let isInFrontOfSphere = sinf(viewCameraSphericalCoord.latitude) >= 0.0
            viewCameraSphericalCoord.longitude += (isInFrontOfSphere ? angleDelta.x : -angleDelta.x)
            
            scene!.viewCamera.transform.position = viewCameraSphericalCoord.getPosition()
            scene!.viewCamera.camera.look(at: viewCameraSphericalCoord.center, up: (isInFrontOfSphere ? SIMD3<Float>.up : SIMD3<Float>.down))
            
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
            
            let ndcZ = scene!.viewCamera.camera.convertWorldToNDC(viewCameraSphericalCoord.center).z
            
            let prevScenePos = scene!.viewCamera.camera.convertViewportToWorld(SIMD3<Float>(gesturePrevPos, ndcZ), viewportSize: graphicsView.bounds.size.simd2)
            let scenePos = scene!.viewCamera.camera.convertViewportToWorld(SIMD3<Float>(pos, ndcZ), viewportSize: graphicsView.bounds.size.simd2)
            
            viewCameraSphericalCoord.center += (prevScenePos - scenePos)
            scene!.viewCamera.transform.position = viewCameraSphericalCoord.getPosition()
            
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
            
            switch scene!.viewCamera.camera.projection {
            case Projection_perspective:
                pinchPrevFingerDist = fingerDistance()
            case Projection_ortographic:
                initialOrtohraphicScale = scene!.viewCamera.camera.orthographicScale
            default:
                assertionFailure()
                break
            }
            
            isNavigating = true
            
        case .changed:
            
            switch scene!.viewCamera.camera.projection {
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
                
                let centerViewportPos = scene!.viewCamera.camera.convertWorldToViewport(viewCameraSphericalCoord.center, viewportSize: graphicsView.bounds.size.simd2)
                var scenePos = scene!.viewCamera.camera.convertViewportToWorld(centerViewportPos + SIMD3<Float>.up * 0.5 * (dist - pinchPrevFingerDist), viewportSize: graphicsView.bounds.size.simd2)
                
                // NOTE: This is needed, because coverting from world to viewport and back gives low precision z value.
                // It is becasue of uneven distribution of world z into ndc z, especially far objects.
                // Alternative could be to make near plane larger but that limits zooming since object will be clipped
                scenePos.z = viewCameraSphericalCoord.center.z
                
                let angle = 0.5 * scene!.viewCamera.camera.fovy * (dist / graphicsView.bounds.size.simd2.y)
                let radiusDelta = length(scenePos - viewCameraSphericalCoord.center) / tanf(angle)
                
                viewCameraSphericalCoord.radius = max(viewCameraSphericalCoord.radius + (dist > pinchPrevFingerDist ? -radiusDelta : radiusDelta), 0.01)
                
                scene!.viewCamera.transform.position = viewCameraSphericalCoord.getPosition()

                pinchPrevFingerDist = dist
                
            case Projection_ortographic:
                
                scene!.viewCamera.camera.orthographicScale = max(initialOrtohraphicScale / Float(pinchGR.scale), 0.01)
                
            default:
                assertionFailure()
                break
            }
            
        default:
            isNavigating = false
        }
        
    }
    
    private var gesturePrevPos = SIMD2<Float>.zero
    private var viewCameraSphericalCoord = SphericalCoord()
    private var shouldResetTwoFingerPan = false
    private var pinchPrevFingerDist: Float = 0.0
    private var shouldResetPinch = false
    private var initialOrtohraphicScale: Float = 1.0
}

