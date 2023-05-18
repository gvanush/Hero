//
//  SceneViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.10.21.
//

import SwiftUI

fileprivate let cameraInitialPosition = SPTPosition(origin: .zero, radius: 150.0, longitude: 0.25 * Float.pi, latitude: 0.25 * Float.pi)
fileprivate let cameraInitialOreintation = SPTOrientation(target: .zero, up: .up, axis: .Z, positive: false)


class SceneViewModel: ObservableObject {
    
    let scene = SPTSceneProxy()
    let xAxisLineMeshId: SPTMeshId
    let yAxisLineMeshId: SPTMeshId
    let zAxisLineMeshId: SPTMeshId
    let xAxisHalfLineMeshId: SPTMeshId
    let circleOutlineMeshId: SPTMeshId
    
    private var prevDragValue: DragGesture.Value?

    private(set) var viewCamera: ViewCamera
    
    private var focusedObjectPositionWillChangeSubscription: SPTAnySubscription?
    
    @Published var focusedObject: SPTObject? {
        willSet {
            if let newValue {
                if isFocusEnabled {
                    updateFocusedObject(newValue)
                }
            } else {
                focusedObjectPositionWillChangeSubscription = nil
            }
        }
    }
    
    @Published var isFocusEnabled = false {
        willSet {
            if newValue {
                if let focusedObject {
                    updateFocusedObject(focusedObject)
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
            if let selectedObject {
                SPTOutlineLook.destroy(object: selectedObject)
            }
            if let newValue {
                SPTOutlineLook.make(.init(color: UIColor.primarySelectionColor.rgba, thickness: 5.0, categories: LookCategories.guide.rawValue), object: newValue)
            }
            focusedObject = newValue
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
        xAxisLineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "x_axis_line", ofType: "obj")!)
        yAxisLineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "y_axis_line", ofType: "obj")!)
        zAxisLineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "z_axis_line", ofType: "obj")!)
        
        xAxisHalfLineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "x_axis_half_line", ofType: "obj")!)
        
        let circleOutlinePath = Bundle.main.path(forResource: "circle_outline", ofType: "obj")!
        circleOutlineMeshId = SPTCreatePolylineFromFile(circleOutlinePath)
        
        // Setup view camera
        viewCamera = .init(sptObject: scene.makeObject())
        
        // Setup coordinate grid
        let gridPath = Bundle.main.path(forResource: "coordinate_grid", ofType: "obj")!
        let gridPolylineId = SPTCreatePolylineFromFile(gridPath)
        let gridObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.coordinateGridColor.rgba, polylineId: gridPolylineId, thickness: .guideLineThinThickness, categories: LookCategories.guide.rawValue), object: gridObject)
        
        // Setup coordinate axis
        let xAxisObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: xAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer1, object: xAxisObject)
        
        let zAxisObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId: zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
        SPTScale.make(.init(xyz: simd_float3(1.0, 1.0, 500.0)), object: zAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer1, object: zAxisObject)
        
    }
    
    func pickObjectAt(_ location: CGPoint, viewportSize: CGSize) -> SPTObject? {
        let locationInScene = viewCamera.convertViewportToWorld(point: .init(location.float2, 1.0), viewportSize: viewportSize.float2)
        let cameraPos = viewCamera.position.toCartesian.cartesian
        
        let object = SPTRayCastScene(scene.handle, SPTRay(origin: cameraPos, direction: locationInScene - cameraPos), 0.0001).object
        
        if SPTIsNull(object) {
            return nil
        }
        
        return object
    }
    
    func resetCamera() {
        isFocusEnabled = false
        viewCamera.reset()
    }
    
    private func focusOn(_ object: SPTObject, animated: Bool) {
        viewCamera.focusOn(SPTPosition.get(object: object).toCartesian.cartesian, animated: animated)
    }
    
    func cameraUp(latitude: Float) -> simd_float3 {
        sinf(latitude) >= 0.0 ? .up : .down
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
        
        viewCamera.orbit(deltaAngle: deltaAngle)
        
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
        
        viewCamera.zoom(deltaY: Self.zoomFactor * deltaYTranslation, viewportSize: viewportSize)
        
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
        
        viewCamera.pan(translation: deltaTranslation, viewportSize: viewportSize)
        
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
            viewCamera.focusOn(newPos.toCartesian.cartesian, animated: false)
        }
        focusOn(object, animated: true)
    }
    
    func makeTwin(object: SPTObject) -> SPTObject {
        let twinObject = scene.makeObject()
        SPTPosition.make(SPTPosition.get(object: object), object: twinObject)
        SPTScale.make(SPTScale.get(object: object), object: twinObject)
        SPTOrientation.make(SPTOrientation.get(object: object), object: twinObject)
        
        var meshLook = SPTMeshLook.get(object: object)
        meshLook.categories &= ~LookCategories.renderableModel.rawValue
        SPTMeshLook.update(meshLook, object: object)
        
        meshLook.categories = LookCategories.guide.rawValue
        SPTMeshLook.make(meshLook, object: twinObject)
        
        if var outlineLook = SPTOutlineLook.tryGet(object: object) {
            SPTOutlineLook.make(outlineLook, object: twinObject)
            
            outlineLook.categories &= ~LookCategories.guide.rawValue
            SPTOutlineLook.update(outlineLook, object: object)
        }
        
        return twinObject
    }
    
    func destroyTwin(_ twinObject: SPTObject, object: SPTObject) {
        var meshLook = SPTMeshLook.get(object: object)
        meshLook.categories |= LookCategories.renderableModel.rawValue
        SPTMeshLook.update(meshLook, object: object)
        
        if var outlineLook = SPTOutlineLook.tryGet(object: object) {
            outlineLook.categories |= LookCategories.guide.rawValue
            SPTOutlineLook.update(outlineLook, object: object)
        }
        
        // TODO: Single destroy spot
        let runLoopObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, false, 0, { _, _ in
            SPTSceneProxy.destroyObject(twinObject)
        })
        CFRunLoopAddObserver(CFRunLoopGetCurrent(), runLoopObserver, .defaultMode)
    }
    
    static let zoomFactor: Float = 3.0
    
}
