//
//  SceneViewModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 26.10.21.
//

import SwiftUI


class SceneViewModel: ObservableObject {
    
    let scene = SPTSceneProxy()

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
        
        viewCamera = .init(sptObject: scene.makeObject())
        
        // Setup coordinate grid
        let gridObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.coordinateGridColor.rgba, polylineId: MeshRegistry.util.coordinateGridePolylineId, thickness: .guideLineThinThickness, categories: LookCategories.guide.rawValue), object: gridObject)
        
        // Setup coordinate axis
        let xAxisObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: xAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer1, object: xAxisObject)
        
        let zAxisObject = scene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId: MeshRegistry.util.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
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
    
    private func updateFocusedObject(_ object: SPTObject) {
        focusedObjectPositionWillChangeSubscription = SPTPosition.onWillChangeSink(object: object) { [unowned self] newPos in
            viewCamera.focusOn(newPos.toCartesian.cartesian, animated: false)
        }
        viewCamera.focusOn(SPTPosition.get(object: object).toCartesian.cartesian, animated: true)
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
    
}
