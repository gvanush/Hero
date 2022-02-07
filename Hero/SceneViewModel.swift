//
//  SceneViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.10.21.
//

import SwiftUI


class SceneViewModel: ObservableObject {
    
    let scene = SPTScene()
    
    private var prevDragValue: DragGesture.Value?

    private(set) var viewCameraObject: SPTObject
    
    @Published var selectedObject: SPTObject? {
        willSet {
            if let selectedObject = selectedObject {
                SPTDestroyOutlineView(selectedObject)
            }
            if let newSelectedObject = newValue {
                let meshView = SPTGetMeshView(newSelectedObject)
                SPTMakeOutlineView(newSelectedObject, meshView.meshId, UIColor.objectSelectionColor.rgba, 5.0)
            }
        }
    }

    init() {
        
        // Setup view camera
        viewCameraObject = scene.makeObject()
        SPTMakeSphericalPosition(viewCameraObject, simd_float3.zero, 300.0, 0.25 * Float.pi, 0.25 * Float.pi)
        SPTMakeLookAtOrientation(viewCameraObject, simd_float3.zero, SPTAxisZ, false, simd_float3.up)
        SPTMakePerspectiveCamera(viewCameraObject, Float.pi / 3.0, 1.0, 0.1, 2000.0)
//        SPTMakeOrthographicCamera(viewCameraObject, 100.0, 1.0, 0.1, 2000.0)
        
        // Setup coordinate grid
        let gridPath = Bundle.main.path(forResource: "coordinate_grid", ofType: "obj")!
        let gridPolylineId = SPTCreatePolylineFromFile(gridPath)
        let gridObject = scene.makeObject()
        SPTMakePolylineView(gridObject, gridPolylineId, UIColor.systemGray.rgba, 1.0)
        
        // Setup coordinate axis
        let linePath = Bundle.main.path(forResource: "line", ofType: "obj")!
        let lineId = SPTCreatePolylineFromFile(linePath)
        
        let xAxisObject = scene.makeObject()
        SPTMakePolylineView(xAxisObject, lineId, UIColor.red.rgba, 2.0)
        SPTMakeScale(xAxisObject, 500.0, 1.0, 1.0)
        SPTMakePolylineViewDepthBias(xAxisObject, 5.0, 3.0, 0.0)
        
        let zAxisObject = scene.makeObject()
        SPTMakePolylineView(zAxisObject, lineId, UIColor.blue.rgba, 2.0)
        SPTMakeScale(zAxisObject, 500.0, 1.0, 1.0)
        SPTMakeEulerOrientation(zAxisObject, simd_float3(0.0, Float.pi * 0.5, 0.0), SPTEulerOrderXYZ)
        SPTMakePolylineViewDepthBias(zAxisObject, 5.0, 3.0, 0.0)
        
        
        // Setup objects
        let centerObjectMeshId = MeshRegistry.standard.recordNamed("sphere")!.id
        let centerObject = scene.makeObject()
        SPTMakePosition(centerObject, 0.0, 0.0, 0.0)
        SPTMakeScale(centerObject, 20.0, 20.0, 20.0)
        SPTMakeEulerOrientation(centerObject, simd_float3(0.0, 0.0, 0.0), SPTEulerOrderXYZ)
        SPTMakeBlinnPhongMeshView(centerObject, centerObjectMeshId, UIColor.darkGray.rgba, 128.0)
        SPTMakeRayCastableMesh(centerObject, centerObjectMeshId)
        
        /*let positionRange: ClosedRange<Float> = -1000.0...1000.0
        let scaleRange: ClosedRange<Float> = 10.0...40.0
        for _ in 0..<1000 {
            let object = scene.makeObject()
            SPTMakePosition(object, Float.random(in: positionRange), Float.random(in: positionRange), Float.random(in: positionRange))
            SPTMakeScale(object, Float.random(in: scaleRange), Float.random(in: scaleRange), Float.random(in: scaleRange))
            SPTMakeEulerOrientation(object, simd_float3(0.0, 0.0, Float.random(in: -Float.pi...Float.pi)), SPTEulerOrderXYZ)
            let meshId = meshRecords.randomElement()!.id
            SPTMakeBlinnPhongMeshView(object, meshId, UIColor.random().rgba, Float.random(in: 2.0...256.0))
            SPTMakeRayCastableMesh(object, meshId)
        }*/
        
    }
    
    var isObjectSelected: Bool {
        selectedObject != nil
    }
    
    func pickObjectAt(_ location: CGPoint, viewportSize: CGSize) -> SPTObject? {
        let locationInScene = SPTCameraConvertViewportToWorld(viewCameraObject, simd_float3(location.float2, 1.0), viewportSize.float2)
        let cameraPos = SPTGetPositionFromSphericalPosition(SPTGetSphericalPosition(viewCameraObject))
        
        let object = SPTRayCastScene(scene.cpp(), SPTRay(origin: cameraPos, direction: locationInScene - cameraPos), 0.0001).object
        
        if SPTIsNull(object) {
            return nil
        }
        
        return object
    }
    
    func focusOn(_ object: SPTObject) {
        
        var sphericalPos = SPTGetSphericalPosition(viewCameraObject)
        sphericalPos.center = SPTGetPosition(object)
        SPTUpdateSphericalPosition(viewCameraObject, sphericalPos)
        
        var lookAtOrientation = SPTGetLookAtOrientation(viewCameraObject)
        lookAtOrientation.target = sphericalPos.center
        SPTUpdateLookAtOrientation(viewCameraObject, lookAtOrientation)
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
        
        var sphericalPos = SPTGetSphericalPosition(viewCameraObject)
        
        sphericalPos.latitude -= deltaAngle.y
        
        let isInFrontOfSphere = sinf(sphericalPos.latitude) >= 0.0
        sphericalPos.longitude += (isInFrontOfSphere ? -deltaAngle.x : deltaAngle.x)
        
        SPTUpdateSphericalPosition(viewCameraObject, sphericalPos)
        
        var lookAtOrientation = SPTGetLookAtOrientation(viewCameraObject)
        lookAtOrientation.up = (isInFrontOfSphere ? simd_float3.up : simd_float3.down)
        
        SPTUpdateLookAtOrientation(viewCameraObject, lookAtOrientation)
        
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
        
        var sphericalPos = SPTGetSphericalPosition(viewCameraObject)
        
        let centerViewportPos = SPTCameraConvertWorldToViewport(viewCameraObject, sphericalPos.center, viewportSize.float2);
        
        var scenePos = SPTCameraConvertViewportToWorld(viewCameraObject, centerViewportPos + simd_float3.up * deltaYTranslation, viewportSize.float2)
        
        // NOTE: This is needed, because coverting from world to viewport and back gives low precision z value.
        // It is becasue of uneven distribution of world z into ndc z, especially far objects.
        // Alternative could be to make near plane larger but that limits zooming since object will be clipped
        scenePos.z = sphericalPos.center.z
        
        let deltaRadius = length(scenePos - sphericalPos.center)
        
        sphericalPos.radius = max(sphericalPos.radius + sign(deltaYTranslation) * Self.zoomFactor * deltaRadius, 0.01)
        
        SPTUpdateSphericalPosition(viewCameraObject, sphericalPos)
        
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
