//
//  SceneGraph.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import Foundation
import SwiftUI

enum ObjectType: Int32 {
    case mesh
}

class SceneGraph: ObservableObject {
    
    let scene: SPTSceneProxy
    private var meshNumber = 1
    private var generatorNumber = 1
    
    @Published var rootObjects = [SPTObject]()
    
    init(scene: SPTSceneProxy) {
        self.scene = scene
    }
    
    func makeMesh(meshId: SPTMeshId, lookCategories: LookCategories, position: simd_float3, scale: Float = 1.0) -> SPTObject {
        
        let object = scene.makeObject()
        SPTMetadataMake(object, .init(tag: ObjectType.mesh.rawValue, name: "Mesh.\(meshNumber)"))
        SPTPosition.make(.init(cartesian: position), object: object)
        SPTScaleMake(object, .init(uniform: scale))
        SPTOrientation.make(.init(eulerXYZ: .zero), object: object)
        SPTMeshLook.make(.init(material: SPTPhongMaterial(color: UIColor.darkGray.sptColor(model: .HSB), shininess: 0.5), meshId: meshId, categories: lookCategories.rawValue), object: object)
        SPTRayCastableMake(object)
        meshNumber += 1
        
        rootObjects.append(object)
        
        return object
    }
    
    func duplicateObject(_ object: SPTObject) -> SPTObject {
        let duplicate = scene.makeObject()
        SPTMetadataMake(duplicate, .init(tag: ObjectType.mesh.rawValue, name: "Mesh.\(meshNumber)"))
        SPTPosition.make(SPTPosition.get(object: object), object: duplicate)
        SPTScale.make(SPTScale.get(object: object), object: duplicate)
        SPTOrientation.make(SPTOrientation.get(object: object), object: duplicate)
        SPTMeshLook.make(SPTMeshLook.get(object: object), object: duplicate)
        SPTRayCastableMake(duplicate)
        
        for property in SPTAnimatableObjectProperty.allCases {
            if let binding = property.tryGetAnimatorBinding(object: object) {
                property.bind(binding, object: duplicate)
            }
        }

        meshNumber += 1
        
        rootObjects.append(object)
        
        return duplicate
    }
    
    func destroyObject(_ object: SPTObject) {
        SPTSceneProxy.destroyObject(object)
        rootObjects.removeAll { $0 == object }
    }
    
    func setParent(_ parent: SPTObject?, object: SPTObject) {
        let parentEntity = parent?.entity ?? kSPTNullEntity
        let oldParent = SPTTransformationGetNode(object).parent
        guard parentEntity != oldParent else {
            return
        }
        
        SPTTransformationSetParent(object, parentEntity)
        if let parent {
            if oldParent == kSPTNullEntity {
                rootObjects.removeAll { $0 == object }
            }
        } else {
            rootObjects.append(object)
        }
        
    }
    
    func makeRandomMeshes(lookCategories: LookCategories) {
        let positionRange: ClosedRange<Float> = -500.0...500.0
        let scaleRange: ClosedRange<Float> = 10.0...40.0
        for _ in 0..<100 {
            let object = scene.makeObject()
            SPTMetadataMake(object, .init(tag: ObjectType.mesh.rawValue, name: "Mesh.\(meshNumber)"))
            SPTPosition.make(.init(x: Float.random(in: positionRange), y: Float.random(in: positionRange), z: Float.random(in: positionRange)), object: object)
            SPTScaleMake(object, .init(xyz: .init(Float.random(in: scaleRange), Float.random(in: scaleRange), Float.random(in: scaleRange))))
            SPTOrientation.make(.init(eulerX: Float.random(in: -Float.pi...Float.pi), y: Float.random(in: -Float.pi...Float.pi), z: Float.random(in: -Float.pi...Float.pi)), object: object)
            let meshId = MeshRegistry.standard.meshRecords.randomElement()!.id
            
            let meshLook = SPTMeshLook(material: SPTPhongMaterial(color: UIColor.random().sptColor(model: .HSB), shininess: Float.random(in: 0.0...1.0)), meshId: meshId, categories: lookCategories.rawValue)
            SPTMeshLook.make(meshLook, object: object)
            
            SPTRayCastableMake(object)
            meshNumber += 1
            
            rootObjects.append(object)
        }
    }
    
}
