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

struct ObjectFactory {
    
    let scene: SPTScene
    
    func makeMesh(meshId: SPTMeshId) -> SPTObject {
        let object = scene.makeObject()
        SPTMetadataMake(object, .init(tag: ObjectType.mesh.rawValue))
        SPTPositionMakeXYZ(object, .zero)
        SPTScaleMake(object, .init(xyz: simd_float3(5.0, 5.0, 5.0)))
        SPTOrientationMakeEuler(object, .init(rotation: .zero, order: .XYZ))
        SPTMeshViewMakeBlinnPhong(object, meshId, UIColor.darkGray.rgba, 128.0)
        SPTRayCastableMake(object)
        return object
    }
    
    func makeRandomMeshes() {
        let positionRange: ClosedRange<Float> = -1000.0...1000.0
        let scaleRange: ClosedRange<Float> = 10.0...40.0
        for _ in 0..<1000 {
            let object = scene.makeObject()
            SPTMetadataMake(object, .init(tag: ObjectType.mesh.rawValue))
            SPTPositionMakeXYZ(object, .init(Float.random(in: positionRange), Float.random(in: positionRange), Float.random(in: positionRange)))
            SPTScaleMake(object, .init(xyz: .init(Float.random(in: scaleRange), Float.random(in: scaleRange), Float.random(in: scaleRange))))
            SPTOrientationMakeEuler(object, .init(rotation: simd_float3(0.0, 0.0, Float.random(in: -Float.pi...Float.pi)), order: .XYZ))
            let meshId = MeshRegistry.standard.meshRecords.randomElement()!.id
            SPTMeshViewMakeBlinnPhong(object, meshId, UIColor.random().rgba, Float.random(in: 2.0...256.0))
            SPTRayCastableMake(object)
        }
    }
    
    func makeGenerator(sourceMeshId: SPTMeshId) -> SPTObject {
        let object = scene.makeObject()
        SPTMetadataMake(object, .init(tag: ObjectType.generator.rawValue))
        SPTPositionMakeXYZ(object, .zero)
        SPTOrientationMakeEuler(object, .init(rotation: .zero, order: .XYZ))
        SPTScaleMake(object, .init(xyz: .one))
        SPTGeneratorMake(object, sourceMeshId, 5)
        SPTRayCastableMake(object)
        return object
    }
    
}
