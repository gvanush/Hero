//
//  SceneViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.10.21.
//

import SwiftUI


class SceneViewModel: ObservableObject {
    
    let scene = SPTScene()
    
    let objectFactory: ObjectFactory
    
    private var prevDragValue: DragGesture.Value?

    private(set) var viewCameraObject: SPTObject
    
    private var objectSelector: ObjectSelector?
    
    @Published var selectedObject: SPTObject? {
        willSet {
            objectSelector = ObjectSelector(object: newValue)
        }
    }

    init() {

        // Setup view camera
        viewCameraObject = scene.makeObject()
        SPTPositionMakeSpherical(viewCameraObject, .init(center: .zero, radius: 150.0, longitude: 0.25 * Float.pi, latitude: 0.25 * Float.pi))
        SPTOrientationMakeLookAt(viewCameraObject, .init(target: .zero, up: .up, axis: .Z, positive: false))
        SPTCameraMakePerspective(viewCameraObject, Float.pi / 3.0, 1.0, 0.1, 2000.0)
//        SPTCameraMakeOrthographic(viewCameraObject, 100.0, 1.0, 0.1, 2000.0)
        
        // Setup coordinate grid
        let gridPath = Bundle.main.path(forResource: "coordinate_grid", ofType: "obj")!
        let gridPolylineId = SPTCreatePolylineFromFile(gridPath)
        let gridObject = scene.makeObject()
        SPTPolylineViewMake(gridObject, gridPolylineId, UIColor.systemGray.rgba, 2.0)
        
        // Setup coordinate axis
        let linePath = Bundle.main.path(forResource: "line", ofType: "obj")!
        let lineId = SPTCreatePolylineFromFile(linePath)
        
        let xAxisObject = scene.makeObject()
        SPTPolylineViewMake(xAxisObject, lineId, UIColor.red.rgba, 3.0)
        SPTScaleMake(xAxisObject, .init(xyz: simd_float3(500.0, 1.0, 1.0)))
        SPTPolylineViewDepthBiasMake(xAxisObject, 5.0, 3.0, 0.0)
        
        let zAxisObject = scene.makeObject()
        SPTPolylineViewMake(zAxisObject, lineId, UIColor.blue.rgba, 3.0)
        SPTScaleMake(zAxisObject, .init(xyz: simd_float3(500.0, 1.0, 1.0)))
        SPTOrientationMakeEuler(zAxisObject, .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ))
        SPTPolylineViewDepthBiasMake(zAxisObject, 5.0, 3.0, 0.0)
        
        objectFactory = ObjectFactory(scene: scene)
        
        // Setup objects
        let centerObjectMeshId = MeshRegistry.standard.recordNamed("cube")!.id
        _ = objectFactory.makeMesh(meshId: centerObjectMeshId)
        
//        objectFactory.makeRandomMeshes()
        
    }
    
    var isObjectSelected: Bool {
        selectedObject != nil
    }
    
    func pickObjectAt(_ location: CGPoint, viewportSize: CGSize) -> SPTObject? {
        let locationInScene = SPTCameraConvertViewportToWorld(viewCameraObject, simd_float3(location.float2, 1.0), viewportSize.float2)
        let cameraPos = SPTPositionGetXYZ(viewCameraObject)
        
        let object = SPTRayCastScene(scene.cpp(), SPTRay(origin: cameraPos, direction: locationInScene - cameraPos), 0.0001).object
        
        if SPTIsNull(object) {
            return nil
        }
        
        return object
    }
    
    func focusOn(_ object: SPTObject) {
        
        var cameraPos = SPTPositionGet(viewCameraObject)
        cameraPos.spherical.center = SPTPositionGet(object).xyz
        SPTPositionUpdate(viewCameraObject, cameraPos)
        
        var cameraOrientation = SPTOrientationGet(viewCameraObject)
        cameraOrientation.lookAt.target = cameraPos.spherical.center
        SPTOrientationUpdate(viewCameraObject, cameraOrientation)
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
        
        var cameraPos = SPTPositionGet(viewCameraObject)
        
        cameraPos.spherical.latitude -= deltaAngle.y
        
        let isInFrontOfSphere = sinf(cameraPos.spherical.latitude) >= 0.0
        cameraPos.spherical.longitude += (isInFrontOfSphere ? -deltaAngle.x : deltaAngle.x)
        
        SPTPositionUpdate(viewCameraObject, cameraPos)
        
        var orientation = SPTOrientationGet(viewCameraObject)
        orientation.lookAt.up = (isInFrontOfSphere ? simd_float3.up : simd_float3.down)
        
        SPTOrientationUpdate(viewCameraObject, orientation)
        
    }
    
    func finishOrbit(dragValue: DragGesture.Value) {
        // Deliberately ignoring last drag value to avoid orbit nudge
        prevDragValue = nil
    }
    
    func cancelOrbit() {
        prevDragValue = nil
    }
    
    static let orbitTranslationPerHalfRevolution: Float = 300.0
    
    // MARK: Zoom
    func zoom(dragValue: DragGesture.Value, viewportSize: CGSize) {
        
        guard let prevDragValue = self.prevDragValue else {
            self.prevDragValue = dragValue
            return
        }
        self.prevDragValue = dragValue
        
        let deltaYTranslation = Float(dragValue.translation.height - prevDragValue.translation.height)
        
        var cameraPos = SPTPositionGet(viewCameraObject)
        
        let centerViewportPos = SPTCameraConvertWorldToViewport(viewCameraObject, cameraPos.spherical.center, viewportSize.float2);
        
        var scenePos = SPTCameraConvertViewportToWorld(viewCameraObject, centerViewportPos + simd_float3.up * deltaYTranslation, viewportSize.float2)
        
        // NOTE: This is needed, because coverting from world to viewport and back gives low precision z value.
        // It is becasue of uneven distribution of world z into ndc z, especially far objects.
        // Alternative could be to make near plane larger but that limits zooming since object will be clipped
        scenePos.z = cameraPos.spherical.center.z
        
        let deltaRadius = length(scenePos - cameraPos.spherical.center)
        
        cameraPos.spherical.radius = max(cameraPos.spherical.radius + sign(deltaYTranslation) * Self.zoomFactor * deltaRadius, 0.01)
        
        SPTPositionUpdate(viewCameraObject, cameraPos)
        
    }
    
    func finishZoom(dragValue: DragGesture.Value, viewportSize: CGSize) {
        // Deliberately ignoring last drag value to avoid zoom nudge
        prevDragValue = nil
    }
    
    func cancelZoom() {
        prevDragValue = nil
    }
    
    static let zoomFactor: Float = 3.0
    
}
