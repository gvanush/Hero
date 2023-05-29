//
//  MainScene.swift
//  Hero
//
//  Created by Vanush Grigoryan on 22.05.23.
//

import Foundation
import Combine
import UIKit


final class MainScene: Scene {
    
    typealias AnyUserObject = any UserObject<MainScene>
    
    let sptScene: SPTSceneProxy
    @Published fileprivate(set) var userManagedRootObjects = [AnyUserObject]()
    var userObjectCounter: UInt = 0
    
    @Published private var allObjects = [SPTEntity: any Object<MainScene>]()
    
    private(set) var viewCamera: ViewCamera<MainScene>
    
    private var focusedObjectCancellable: AnyCancellable?
    private var sptObjectsToDestroy = [SPTObject]()
    
    init() {
        self.sptScene = .init()
        viewCamera = .init(sptObject: sptScene.makeObject())
        setupGuides()
    }
    
    private func setupGuides() {
        
        // Setup coordinate grid
        let gridObject = sptScene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.coordinateGridColor.rgba, polylineId: MeshRegistry.util.coordinateGridePolylineId, thickness: .guideLineThinThickness, categories: LookCategories.guide.rawValue), object: gridObject)
        
        // Setup coordinate axis
        let xAxisObject = sptScene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.xAxis.rgba, polylineId: MeshRegistry.util.xAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: xAxisObject)
        SPTScale.make(.init(xyz: simd_float3(500.0, 1.0, 1.0)), object: xAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer1, object: xAxisObject)
        
        let zAxisObject = sptScene.makeObject()
        SPTPolylineLook.make(.init(color: UIColor.zAxis.rgba, polylineId: MeshRegistry.util.zAxisLineMeshId, thickness: .guideLineRegularThickness, categories: LookCategories.guide.rawValue), object: zAxisObject)
        SPTScale.make(.init(xyz: simd_float3(1.0, 1.0, 500.0)), object: zAxisObject)
        SPTLineLookDepthBias.make(.guideLineLayer1, object: zAxisObject)
        
    }
    
    @Published var selectedObject: (AnyUserObject)? {
        willSet {
            guard selectedObject !== newValue else {
                return
            }
            if let selectedObject {
                selectedObject._isSelected = false
            }
            if let newValue {
                assert(newValue.scene === self)
                newValue._isSelected = true
            }
            focusedObject = newValue
        }
    }
    
    var isObjectSelected: Bool {
        return selectedObject != nil
    }
    
    @Published var focusedObject: (any LocatableObject)? {
        willSet {
            if let newValue {
                assert(newValue.scene === self)
                if isFocusEnabled {
                    updateFocusedObject(newValue)
                }
            } else {
                focusedObjectCancellable = nil
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
                focusedObjectCancellable = nil
            }
        }
    }
    
    private func updateFocusedObject(_ object: any LocatableObject) {
        
        focusedObjectCancellable = object.objectWillChange.sink { [unowned self] in
            // TODO
            self.viewCamera.focusOn(object.position.toCartesian.cartesian, animated: false)
        }
        
        // TODO
        viewCamera.focusOn(object.position.toCartesian.cartesian, animated: true)
    }
    
    func pickObjectAt(_ location: CGPoint, viewportSize: CGSize) -> (AnyUserObject)? {
        let locationInScene = viewCamera.convertViewportToWorld(point: .init(location.float2, 1.0), viewportSize: viewportSize.float2)
        let cameraPos = viewCamera.position.toCartesian.cartesian
        
        let object = SPTRayCastScene(sptScene.handle, SPTRay(origin: cameraPos, direction: locationInScene - cameraPos), 0.0001).object
        
        if SPTIsNull(object) {
            return nil
        }
        
        return allObjects[object.entity] as? AnyUserObject
    }
    
    func makeObject<O>(_ builder: (SPTObject, UInt) -> O) -> O where O: UserObject<MainScene> {
        userObjectCounter += 1
        let object = builder(sptScene.makeObject(), userObjectCounter)
        object._scene = self
        userManagedRootObjects.append(object)
        allObjects[object.sptObject.entity] = object
        return object
    }
    
    func makeObject<O>(_ builder: (SPTObject) -> O) -> O where O: Object<MainScene> {
        objectWillChange.send()
        let object = builder(sptScene.makeObject())
        object._scene = self
        if let object = object as? AnyUserObject {
            userManagedRootObjects.append(object)
        }
        allObjects[object.sptObject.entity] = object
        return object
    }
    
    func _addRootUserObject(_ object: AnyUserObject) {
        userManagedRootObjects.append(object)
    }
    
    func _removeRootUserObject(_ object: AnyUserObject) {
        userManagedRootObjects.removeAll { $0 === object }
    }
    
    func _getObject(entity: SPTEntity) -> (any Object<MainScene>)? {
        allObjects[entity]
    }
    
    func _destroyObject(_ object: any Object<MainScene>) -> Bool {
        
        guard let _ = allObjects.removeValue(forKey: object.sptObject.entity) else {
            return false
        }
        
        if selectedObject === object {
            selectedObject = nil
        }
        
        if focusedObject === object {
            focusedObject = nil
        }
        
        if sptObjectsToDestroy.isEmpty {
            
            let runLoopObserver = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, false, 0, { _, _ in
                
                for sptObject in self.sptObjectsToDestroy {
                    SPTSceneProxy.destroyObject(sptObject)
                }
                self.sptObjectsToDestroy.removeAll()
                
            })
            CFRunLoopAddObserver(CFRunLoopGetCurrent(), runLoopObserver, .defaultMode)
            
        }
        
        sptObjectsToDestroy.append(object.sptObject)
        
        return true
    }
    
    func makeTwin(object: SPTObject) -> SPTObject {
        // TODO
        let twinObject = sptScene.makeObject()
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
        // TODO
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
