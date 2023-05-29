//
//  SceneGraph.swift
//  Hero
//
//  Created by Vanush Grigoryan on 20.05.23.
//

import Foundation
import Combine


// MARK: Object
protocol Scene: ObservableObject
where ObjectWillChangePublisher == ObservableObjectPublisher {
    
    func makeObject<O>(_ builder: (SPTObject) -> O) -> O where O: Object<Self>
    
    func _getObject(entity: SPTEntity) -> (any Object<Self>)?
    
    func _destroyObject(_ object: any Object<Self>) -> Bool
    
}


// MARK: Object
protocol Object<S>: ObservableObject, Identifiable
where ObjectWillChangePublisher == ObservableObjectPublisher, ID == ObjectIdentifier {
    
    var sptObject: SPTObject { get }
    
    associatedtype S: Scene
    var _scene: S! { get set }
    
    func die()
    
}

extension Object {
    
    var scene: S {
        _scene!
    }
    
    var transformationParent: (any Object<S>)? {
        get {
            scene._getObject(entity: SPTTransformationGetNode(sptObject).parent)
        }
        set {
            let parent = transformationParent
            guard parent !== newValue else {
                return
            }
            parent?.objectWillChange.send()
            newValue?.objectWillChange.send()
            objectWillChange.send()
            SPTTransformationSetParent(sptObject, newValue?.sptObject.entity ?? kSPTNullEntity)
        }
    }
    
    var transformationChildren: [any Object<S>] {
        var children = [any Object<S>]()
        var childEntity = SPTTransformationGetNode(sptObject).firstChild
        while childEntity != kSPTNullEntity {
            children.append(scene._getObject(entity: childEntity)!)
            childEntity = SPTTransformationGetNode(.init(entity: childEntity, sceneHandle: sptObject.sceneHandle)).nextSibling
        }
        return children
    }
    
    func getTransformationChildren() -> [any Object] {
        var children = [any Object]()
        var childEntity = SPTTransformationGetNode(sptObject).firstChild
        while childEntity != kSPTNullEntity {
            children.append(scene._getObject(entity: childEntity)!)
            childEntity = SPTTransformationGetNode(.init(entity: childEntity, sceneHandle: sptObject.sceneHandle)).nextSibling
        }
        return children
    }
    
    func die() {
        transformationParent?.objectWillChange.send()
        guard scene._destroyObject(self) else {
            fatalError()
        }
    }
    
}

// MARK: LocatableObject
protocol LocatableObject: Object {
    
}

extension LocatableObject {
    
    var position: SPTPosition {
        get {
            SPTPosition.get(object: sptObject)
        }
        set {
            objectWillChange.send()
            SPTPosition.update(newValue, object: sptObject)
        }
    }
    
    func _buildLocatableObject(position: SPTPosition = .init()) {
        SPTPosition.make(position, object: sptObject)
    }
    
    func _cloneLocatableObject(original: SPTObject) {
        SPTPosition.make(.get(object: original), object: sptObject)
    }
    
}

// MARK: OrientableObject
protocol OrientableObject: Object {
    
}

extension OrientableObject {
    
    var orientation: SPTOrientation {
        get {
            SPTOrientation.get(object: sptObject)
        }
        set {
            objectWillChange.send()
            SPTOrientation.update(newValue, object: sptObject)
        }
    }
    
    func _buildOrientableObject(orientation: SPTOrientation = .init()) {
        SPTOrientation.make(orientation, object: sptObject)
    }
    
    func _cloneOrientableObject(original: SPTObject) {
        SPTOrientation.make(.get(object: original), object: sptObject)
    }
    
}

// MARK: ScalableObject
protocol ScalableObject: Object {
    
}

extension ScalableObject {
    
    var scale: SPTScale {
        get {
            SPTScale.get(object: sptObject)
        }
        set {
            objectWillChange.send()
            SPTScale.update(newValue, object: sptObject)
        }
    }
    
    func _buildScalableObject(scale: SPTScale = .init()) {
        SPTScale.make(scale, object: sptObject)
    }
    
    func _cloneScalableObject(original: SPTObject) {
        SPTScale.make(.get(object: original), object: sptObject)
    }
    
}


// MARK: MeshObject
protocol MeshObject: Object {
    
}

extension MeshObject {
    
    var meshLook: SPTMeshLook {
        get {
            SPTMeshLook.get(object: sptObject)
        }
        set {
            SPTMeshLook.update(newValue, object: sptObject)
        }
    }
    
    func _buildMeshObject(meshLook: SPTMeshLook) {
        SPTMeshLook.make(meshLook, object: sptObject)
    }
    
    func _cloneMeshObject(original: SPTObject) {
        SPTMeshLook.make(.get(object: original), object: sptObject)
    }
    
}

// MARK: CameraObject
protocol CameraObject: Object {
    
}

extension CameraObject {
    
    func convertViewportToWorld(point: simd_float3, viewportSize: simd_float2) -> simd_float3 {
        SPTCameraConvertViewportToWorld(sptObject, point, viewportSize)
    }
    
}


// MARK: RayCastableObject: Object
protocol RayCastableObject: Object {
    
}

extension RayCastableObject {
    
    func _buildRayCastableObject() {
        SPTRayCastableMake(sptObject)
    }
    
    func _cloneRayCastableObject(original: SPTObject) {
        SPTRayCastableMake(sptObject)
    }
    
}
