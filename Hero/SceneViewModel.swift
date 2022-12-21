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
    let halfLineMeshId: SPTMeshId
    let circleOutlineMeshId: SPTMeshId
    
    private var prevDragValue: DragGesture.Value?
    private var orbitDirection: Float = 1.0

    private(set) var viewCameraObject: SPTObject
    
    private var objectSelector: ObjectSelector?
    private var focusedObjectPositionWillChangeSubscription: SPTAnySubscription?
    
    @Published var focusedObject: SPTObject? {
        willSet {
            if let newObject = newValue {
                if isFocusEnabled {
                    updateFocusedObject(newObject)
                }
            } else {
                focusedObjectPositionWillChangeSubscription = nil
            }
        }
    }
    
    @Published var isFocusEnabled = false {
        willSet {
            if newValue {
                if let object = focusedObject {
                    updateFocusedObject(object)
                }
            } else {
                focusedObjectPositionWillChangeSubscription = nil
            }
        }
    }
    
    @Published var selectedObject: SPTObject? {
        willSet {
            guard selectedObject != newValue else {
                return
            }
            focusedObject = newValue
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

        // Setup meshes
        let linePath = Bundle.main.path(forResource: "line", ofType: "obj")!
        lineMeshId = SPTCreatePolylineFromFile(linePath)
        
        let halfLinePath = Bundle.main.path(forResource: "half_line", ofType: "obj")!
        halfLineMeshId = SPTCreatePolylineFromFile(halfLinePath)
        
        let circleOutlinePath = Bundle.main.path(forResource: "circle_outline", ofType: "obj")!
        circleOutlineMeshId = SPTCreatePolylineFromFile(circleOutlinePath)
        
        // Setup view camera
        viewCameraObject = scene.makeObject()
        SPTPosition.make(.init(origin: .zero, radius: 150.0, longitude: 0.25 * Float.pi, latitude: 0.25 * Float.pi), object: viewCameraObject)
        SPTOrientation.make(.init(target: .zero, up: .up, axis: .Z, positive: false), object: viewCameraObject)
        SPTCameraMakePerspective(viewCameraObject, Float.pi / 3.0, 1.0, 0.1, 2000.0)
        
        // Setup coordinate grid
        let gridPath = Bundle.main.path(forResource: "coordinate_grid", ofType: "obj")!
        let gridPolylineId = SPTCreatePolylineFromFile(gridPath)
        let gridObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.coordinateGridColor.rgba, polylineId: gridPolylineId, thickness: .guideLineThinThickness, categories: LookCategories.guide.rawValue), object: gridObject)
        
        // Setup coordinate axis
        let xAxisObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: xAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer1, object: xAxisObject)
        
        let zAxisObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId: lineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
        
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: zAxisObject)
        SPTOrientation.make(.init(euler: .init(rotation: .init(0.0, Float.pi * 0.5, 0.0), order: .XYZ)), object: zAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer1, object: zAxisObject)
        
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
    
    private func focusOn(_ object: SPTObject, animated: Bool) {
        focusOn(SPTPositionGet(object).toCartesian.cartesian, animated: animated)
    }
    
    private func focusOn(_ point: simd_float3, animated: Bool) {
        
        var cameraPos = SPTPosition.get(object: viewCameraObject)
        
        let initialSin = sign(sinf(cameraPos.spherical.latitude))
        
        cameraPos = cameraPos.toSpherical(origin: point)
        
        if initialSin != sign(sinf(cameraPos.spherical.latitude)) {
            // Maintaining same position but with original latitude sign to match with old camera orientation along z axis
            cameraPos.spherical.latitude = -cameraPos.spherical.latitude
            cameraPos.spherical.longitude += Float.pi
        }
        
        SPTPosition.update(cameraPos, object: viewCameraObject)
        
        var cameraOrientation = SPTOrientation.get(object: viewCameraObject)
        cameraOrientation.lookAtPoint.up = cameraUp(latitude: cameraPos.spherical.latitude)
        
        if animated {
            SPTOrientation.update(cameraOrientation, object: viewCameraObject)
            SPTOrientationAction.make(lookAtTarget: point, duration: 0.3, easing: .smoothStep, object: viewCameraObject)
        } else {
            cameraOrientation.lookAtPoint.target = point
            SPTOrientation.update(cameraOrientation, object: viewCameraObject)
        }
        
    }
    
    func cameraUp(latitude: Float) -> simd_float3 {
        sinf(latitude) >= 0.0 ? .up : .down
    }
    
    // MARK: Orbit
    func orbit(dragValue: DragGesture.Value) {
        
        guard let prevDragValue = self.prevDragValue else {
            self.prevDragValue = dragValue
            
            let cameraPos = SPTPosition.get(object: viewCameraObject)
            orbitDirection = (simd_dot(.up, cameraPos.toCartesian.cartesian - cameraPos.origin) >= 0.0 ? -1.0 : 1.0)
            
            return
        }
        self.prevDragValue = dragValue
        
        let deltaTranslation = dragValue.translation.float2 - prevDragValue.translation.float2
        let deltaAngle = Float.pi * deltaTranslation / Self.orbitTranslationPerHalfRevolution
        
        var cameraPos = SPTPosition.get(object: viewCameraObject)
        
        cameraPos.spherical.latitude -= deltaAngle.y
        cameraPos.spherical.longitude += orbitDirection * deltaAngle.x
        
        SPTPosition.update(cameraPos, object: viewCameraObject)
        
        var orientation = SPTOrientation.get(object: viewCameraObject)
        orientation.lookAtPoint.up = cameraUp(latitude: cameraPos.spherical.latitude)
        SPTOrientation.update(orientation, object: viewCameraObject)
        
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
        
        var viewportPos = SPTCameraConvertWorldToViewport(viewCameraObject, cameraPos.spherical.origin, viewportSize.float2);
        viewportPos.y += deltaYTranslation
        
        let scenePos = SPTCameraConvertViewportToWorld(viewCameraObject, viewportPos, viewportSize.float2)
        
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
    
    // MARK: Pan
    func pan(dragValue: DragGesture.Value, viewportSize: CGSize) {
        
        // NOTE: Typically the first non-zero drag translation is big which results to
        // aggresive jerk on the start, hence first non-zero translation is ignored
        guard let prevDragValue = self.prevDragValue else {
            if dragValue.translation == .zero {
                return
            }
            self.prevDragValue = dragValue
            return
        }
        self.prevDragValue = dragValue
        
        let deltaTranslation = dragValue.translation.float2 - prevDragValue.translation.float2
        
        var cameraPos = SPTPosition.get(object: viewCameraObject)
        var centerViewportPos = SPTCameraConvertWorldToViewport(viewCameraObject, cameraPos.spherical.origin, viewportSize.float2);
        
        centerViewportPos.x -= deltaTranslation.x
        centerViewportPos.y -= deltaTranslation.y
        
        cameraPos.spherical.origin = SPTCameraConvertViewportToWorld(viewCameraObject, centerViewportPos, viewportSize.float2)
        
        SPTPosition.update(cameraPos, object: viewCameraObject)
        
        var cameraOrientation = SPTOrientation.get(object: viewCameraObject)
        cameraOrientation.lookAtPoint.target = cameraPos.spherical.origin
        SPTOrientation.update(cameraOrientation, object: viewCameraObject)
    }
    
    func finishPan(dragValue: DragGesture.Value, viewportSize: CGSize) {
        // Deliberately ignoring last drag value to avoid pan nudge
        prevDragValue = nil
    }
    
    func cancelPan() {
        prevDragValue = nil
    }
    
    private func updateFocusedObject(_ object: SPTObject) {
        focusedObjectPositionWillChangeSubscription = SPTPosition.onWillChangeSink(object: object) { [unowned self] newPos in
            self.focusOn(newPos.toCartesian.cartesian, animated: false)
        }
        focusOn(object, animated: true)
    }
    
    static let zoomFactor: Float = 3.0
    
}
