//
//  ObjectFactory.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import Foundation
import SwiftUI

enum ObjectType: Int32 {
    case mesh
    case generator
}

class ObjectFactory {
    
    let scene: SPTSceneProxy
    private var meshNumber = 1
    private var generatorNumber = 1
    
    init(scene: SPTSceneProxy) {
        self.scene = scene
    }
    
    func makeMesh(meshId: SPTMeshId) -> SPTObject {
        let object = scene.makeObject()
        SPTMetadataMake(object, .init(tag: ObjectType.mesh.rawValue, name: "Mesh \(meshNumber)"))
        SPTPosition.make(.init(x: 0.0, y: 5.0, z: 0.0), object: object)
        SPTScaleMake(object, .init(xyz: simd_float3(5.0, 5.0, 5.0)))
        SPTOrientationMakeEuler(object, .init(rotation: .zero, order: .XYZ))
        SPTMeshLook.make(.init(material: SPTPhongMaterial(color: UIColor.darkGray.rgba, specularRoughness: 128.0), meshId: meshId, categories: LookCategories.userCreated.rawValue), object: object)
        SPTRayCastableMake(object)
        meshNumber += 1
        return object
    }
    
    func makeRandomMeshes() {
        let positionRange: ClosedRange<Float> = -500.0...500.0
        let scaleRange: ClosedRange<Float> = 10.0...40.0
        for _ in 0..<100 {
            let object = scene.makeObject()
            SPTMetadataMake(object, .init(tag: ObjectType.mesh.rawValue, name: "Mesh \(meshNumber)"))
            SPTPositionMakeXYZ(object, .init(Float.random(in: positionRange), Float.random(in: positionRange), Float.random(in: positionRange)))
            SPTScaleMake(object, .init(xyz: .init(Float.random(in: scaleRange), Float.random(in: scaleRange), Float.random(in: scaleRange))))
            SPTOrientationMakeEuler(object, .init(rotation: simd_float3(0.0, 0.0, Float.random(in: -Float.pi...Float.pi)), order: .XYZ))
            let meshId = MeshRegistry.standard.meshRecords.randomElement()!.id
            
            let meshLook = SPTMeshLook(material: SPTPhongMaterial(color: UIColor.random().rgba, specularRoughness: Float.random(in: 2.0...256.0)), meshId: meshId, categories: LookCategories.userCreated.rawValue)
            SPTMeshLook.make(meshLook, object: object)
            
            SPTRayCastableMake(object)
            meshNumber += 1
        }
    }
    
    func makeGenerator(sourceMeshId: SPTMeshId) -> SPTObject {
        let object = scene.makeObject()
        SPTMetadataMake(object, .init(tag: ObjectType.generator.rawValue, name: "Generator \(generatorNumber)"))
        SPTPositionMakeXYZ(object, .zero)
        SPTOrientationMakeEuler(object, .init(rotation: .zero, order: .XYZ))
        SPTScaleMake(object, .init(xyz: .one))
        SPTGenerator.make(.init(quantity: 5, sourceMeshId: sourceMeshId), object: object)
        SPTRayCastableMake(object)
        generatorNumber += 1
        return object
    }
    
}
