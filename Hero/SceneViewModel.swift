//
//  SceneViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.10.21.
//

import SwiftUI

class SceneViewModel: ObservableObject {
    let scene = SPTScene()
    
    init() {
        setupCamera()
    }
    
    private(set) var viewCameraEntity = spt_k_null_entity {
        willSet {
            objectWillChange.send()
        }
    }
    
    func pickObjectAt(_ location: CGPoint, viewportSize: CGSize) -> SceneObject? {
        nil
    }
    
    func discardSelection() {
    }
    
    func select(_ object: SceneObject) {
    }
    
    var selectedObject: SceneObject? {
        nil
    }
    
    func orbit(dragValue: DragGesture.Value) {
    }
    
    func finishOrbit(dragValue: DragGesture.Value) {
    }
    
    func zoom(dragValue: DragGesture.Value, viewportSize: CGSize) {
    }
    
    func finishZoom(dragValue: DragGesture.Value, viewportSize: CGSize) {
        
    }
    
    // MARK: Scene setup
    private func setupCamera() {
        
        viewCameraEntity = scene.makeEntity()
        spt_make_perspective_camera(viewCameraEntity, Float.pi / 3.0, 1.0, 0.1, 1000.0)
        
        /*scene.viewCamera.camera!.near = 0.1
        scene.viewCamera.camera!.far = 1000.0
        scene.viewCamera.camera!.fovy = Float.pi / 3.0
        scene.viewCamera.camera!.orthographicScale = 70.0
        
        viewCameraSphericalCoord.radius = 100.0
        viewCameraSphericalCoord.longitude = Float.pi
        viewCameraSphericalCoord.latitude = 0.5 * Float.pi
        scene.viewCamera.transform!.position = spt_position(viewCameraSphericalCoord)*/
    }
    
}

// TODO
/*class SceneViewModel: ObservableObject {
    
    let scene = Scene()
    var viewCameraSphericalCoord = spt_make_spherical_coord()
    private var prevDragValue: DragGesture.Value?
    
    init() {
        setupCamera()
        setupAxis()
        addImages()
    }
    
    // MARK: Object Selection
    func pickObjectAt(_ location: CGPoint, viewportSize: CGSize) -> SceneObject? {
        let scenePos = scene.viewCamera.camera!.convertViewportToWorld(SIMD3<Float>(location.float2, 1.0), viewportSize: viewportSize.float2)
        
        if let object = scene.rayCast(makeRay(scene.viewCamera.transform!.position, scenePos - scene.viewCamera.transform!.position)) {
            return object
        }
        
        return nil
    }
    
    func discardSelection() {
        scene.selectedObject = nil
        objectWillChange.send()
    }
    
    func select(_ object: SceneObject) {
        scene.selectedObject = object
        objectWillChange.send()
    }
    
    var selectedObject: SceneObject? {
        scene.selectedObject
    }
    
    // MARK: Orbit
    func orbit(dragValue: DragGesture.Value) {
        
        guard let prevDragValue = self.prevDragValue else {
            self.prevDragValue = dragValue
            return
        }
        self.prevDragValue = dragValue
        
        let deltaTranslation = dragValue.translation.float2 - prevDragValue.translation.float2
        let deltaAngle = Float.pi * deltaTranslation / Self.orbitTranslationPerHalfRevolution
        
        viewCameraSphericalCoord.latitude -= deltaAngle.y
        
        let isInFrontOfSphere = sinf(viewCameraSphericalCoord.latitude) >= 0.0
        viewCameraSphericalCoord.longitude += (isInFrontOfSphere ? deltaAngle.x : -deltaAngle.x)
        
        scene.viewCamera.transform!.position = spt_position(viewCameraSphericalCoord)
        scene.viewCamera.camera!.look(at: viewCameraSphericalCoord.center, up: (isInFrontOfSphere ? SIMD3<Float>.up : SIMD3<Float>.down))
    }
    
    func finishOrbit(dragValue: DragGesture.Value) {
        orbit(dragValue: dragValue)
        prevDragValue = nil
    }
    
    static let orbitTranslationPerHalfRevolution: Float = 250.0
    
    // MARK: Zoom
    func zoom(dragValue: DragGesture.Value, viewportSize: CGSize) {
        
        guard let prevDragValue = self.prevDragValue else {
            self.prevDragValue = dragValue
            return
        }
        self.prevDragValue = dragValue
        
        let deltaYTranslation = Float(dragValue.translation.height - prevDragValue.translation.height)
        
        let centerViewportPos = scene.viewCamera.camera!.convertWorldToViewport(viewCameraSphericalCoord.center, viewportSize: viewportSize.float2)
        var scenePos = scene.viewCamera.camera!.convertViewportToWorld(centerViewportPos + SIMD3<Float>.up * deltaYTranslation, viewportSize: viewportSize.float2)
        
        // NOTE: This is needed, because coverting from world to viewport and back gives low precision z value.
        // It is becasue of uneven distribution of world z into ndc z, especially far objects.
        // Alternative could be to make near plane larger but that limits zooming since object will be clipped
        scenePos.z = viewCameraSphericalCoord.center.z
        
        let deltaRadius = length(scenePos - viewCameraSphericalCoord.center)
        
        viewCameraSphericalCoord.radius = max(viewCameraSphericalCoord.radius + sign(deltaYTranslation) * Self.zoomFactor * deltaRadius, 0.01)
        
        scene.viewCamera.transform!.position = spt_position(viewCameraSphericalCoord)
        
    }
    
    func finishZoom(dragValue: DragGesture.Value, viewportSize: CGSize) {
        zoom(dragValue: dragValue, viewportSize: viewportSize)
        prevDragValue = nil
    }
    
    static let zoomFactor: Float = 3.0
    
    // MARK: Scene setup
    private func setupCamera() {
        scene.viewCamera.camera!.near = 0.1
        scene.viewCamera.camera!.far = 1000.0
        scene.viewCamera.camera!.fovy = Float.pi / 3.0
        scene.viewCamera.camera!.orthographicScale = 70.0
        
        viewCameraSphericalCoord.radius = 100.0
        viewCameraSphericalCoord.longitude = Float.pi
        viewCameraSphericalCoord.latitude = 0.5 * Float.pi
        scene.viewCamera.transform!.position = spt_position(viewCameraSphericalCoord)
    }
    
    private func setupAxis() {
        let axisHalfLength: Float = 1000.0
        let axisThickness: Float = 5.0
        
        // xAxis
        scene.makeLine(point1: SIMD3<Float>(-axisHalfLength, 0.0, 0.0), point2: SIMD3<Float>(axisHalfLength, 0.0, 0.0), thickness: axisThickness, color: SIMD4<Float>.red)
        
        // zAxis
        scene.makeLine(point1: SIMD3<Float>(0.0, 0.0, -axisHalfLength), point2: SIMD3<Float>(0.0, 0.0, axisHalfLength), thickness: axisThickness, color: SIMD4<Float>.blue)
    }
    
    private func addImages() {
        let sampleImageCount = 5
        let textureLoader = MTKTextureLoader(device: RenderingContext.device())
        
        for i in 0..<sampleImageCount {
            let texture = try! textureLoader.newTexture(name: "sample_image_\(i)", scaleFactor: 1.0, bundle: nil, options: nil)
            let texRatio = Float(texture.width) / Float(texture.height)
            
            let imageObject = scene.makeImageObject()
            imageObject.textureRenderer!.texture = texture
            if i == 0 {
                let size = Float(30.0)
                imageObject.textureRenderer!.size = (texRatio > 1.0 ? SIMD2<Float>(x: size, y: size / texRatio) : SIMD2<Float>(x: size * texRatio, y: size))
                imageObject.transform!.position = SIMD3<Float>(0.0, 0.0, 20.0)
            } else {
                
                let sizeRange = Float(10.0)...Float(100.0)
                let width = Float.random(in: sizeRange)
                let height = Float.random(in: sizeRange)
                
                let size = min(width, height) / 2.0
                
                let positionRange = Float(-70.0)...Float(70.0)
                imageObject.textureRenderer!.size = (texRatio > 1.0 ? SIMD2<Float>(x: size, y: size / texRatio) : SIMD2<Float>(x: size * texRatio, y: size))
                imageObject.transform!.position = SIMD3<Float>(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: Float.random(in: 0.0...300.0))
            }
        }
    }
    
}
*/
