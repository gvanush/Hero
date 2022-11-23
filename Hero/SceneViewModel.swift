//
//  SceneViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.10.21.
//

import SwiftUI


class SceneViewModel: ObservableObject {
    
    let scene = SPTSceneProxy()
    let lineMeshId: SPTMeshId
    
    private var prevDragValue: DragGesture.Value?

    private(set) var viewCameraObject: SPTObject
    
    private var objectSelector: ObjectSelector?
    private var focusedObjectPositionWillChangeSubscription: SPTAnySubscription?
    
    @Published var focusedObject: SPTObject? {
        willSet {
            if let newObject = newValue {
                focusedObjectPositionWillChangeSubscription = SPTPosition.onWillChangeSink(object: newObject) { newPos in
                    self.focusOn(newPos.cartesian)
                }
                
                focusOn(newObject)
            } else {
                focusedObjectPositionWillChangeSubscription = nil
            }
            
        }
    }
    
    @Published var selectedObject: SPTObject? {
        willSet {
            if let newObject = newValue, selectedObject == newObject {
                focusedObject = newObject
                return
            }
            objectSelector = ObjectSelector(object: newValue)
        }
    }
    
    var isObjectSelected: Bool {
        return selectedObject != nil
    }
    
    var selectedObjectMetadata: SPTMetadata? {
        guard let selectedObject = selectedObject else { return nil }
        return SPTMetadataGet(selectedObject)
    }

    init() {

        // Setup view camera
        viewCameraObject = scene.makeObject()
        SPTPosition.make(.init(origin: .zero, radius: 150.0, longitude: 0.25 * Float.pi, latitude: 0.25 * Float.pi), object: viewCameraObject)
        SPTOrientation.make(.init(lookAt: .init(target: .zero, up: .up, axis: .Z, positive: false)), object: viewCameraObject)
        SPTCameraMakePerspective(viewCameraObject, Float.pi / 3.0, 1.0, 0.1, 2000.0)
//        SPTCameraMakeOrthographic(viewCameraObject, 100.0, 1.0, 0.1, 2000.0)
        
        // Setup coordinate grid
        let gridPath = Bundle.main.path(forResource: "coordinate_grid", ofType: "obj")!
        let gridPolylineId = SPTCreatePolylineFromFile(gridPath)
        let gridObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.systemGray.rgba, polylineId: gridPolylineId, thickness: 2.0, categories: LookCategories.sceneGuide.rawValue), object: gridObject)
        
        // Setup coordinate axis
        let linePath = Bundle.main.path(forResource: "line", ofType: "obj")!
        lineMeshId = SPTCreatePolylineFromFile(linePath)
        
        let xAxisObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: lineMeshId, thickness: 3.0, categories: LookCategories.sceneGuide.rawValue), object: xAxisObject)
        
        SPTScaleMake(xAxisObject, .init(xyz: simd_float3(500.0, 1.0, 1.0)))
        SPTPolylineLookDepthBiasMake(xAxisObject, 5.0, 3.0, 0.0)
        
        let zAxisObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId: lineMeshId, thickness: 3.0, categories: LookCategories.sceneGuide.rawValue), object: zAxisObject)
        
        SPTScaleMake(zAxisObject, .init(xyz: simd_float3(500.0, 1.0, 1.0)))
        SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ)), object: zAxisObject)
        SPTPolylineLookDepthBiasMake(zAxisObject, 5.0, 3.0, 0.0)
        
    }
    
    func pickObjectAt(_ location: CGPoint, viewportSize: CGSize) -> SPTObject? {
        let locationInScene = SPTCameraConvertViewportToWorld(viewCameraObject, simd_float3(location.float2, 1.0), viewportSize.float2)
        let cameraPos = SPTPosition.get(object: viewCameraObject).spherical.toCartesian
        
        let object = SPTRayCastScene(scene.handle, SPTRay(origin: cameraPos, direction: locationInScene - cameraPos), 0.0001).object
        
        if SPTIsNull(object) {
            return nil
        }
        
        return object
    }
    
    private func focusOn(_ object: SPTObject) {
        focusOn(SPTPositionGet(object).cartesian)
    }
    
    private func focusOn(_ point: simd_float3) {
        
        var cameraPos = SPTPositionGet(viewCameraObject)
        cameraPos.spherical.origin = point
        SPTPositionUpdate(viewCameraObject, cameraPos)
        
        var cameraOrientation = SPTOrientationGet(viewCameraObject)
        cameraOrientation.lookAt.target = cameraPos.spherical.origin
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
        
        let centerViewportPos = SPTCameraConvertWorldToViewport(viewCameraObject, cameraPos.spherical.origin, viewportSize.float2);
        
        var scenePos = SPTCameraConvertViewportToWorld(viewCameraObject, centerViewportPos + simd_float3.up * deltaYTranslation, viewportSize.float2)
        
        // NOTE: This is needed, because coverting from world to viewport and back gives low precision z value.
        // It is becasue of uneven distribution of world z into ndc z, especially far objects.
        // Alternative could be to make near plane larger but that limits zooming since object will be clipped
        scenePos.z = cameraPos.spherical.origin.z
        
        let deltaRadius = length(scenePos - cameraPos.spherical.origin)
        
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
