//
//  MeshRegistry.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.02.22.
//

import Foundation


struct MeshRegistry {

    struct MeshRecord: Identifiable {
        let name: String
        let iconName: String
        let id: SPTMeshId
    }
    
    static let standard = MeshRegistry()
    
    private init() {
        for item in ["cube", "cylinder", "cone", "sphere", "torus", "monkey"] {
            let meshPath = Bundle.main.path(forResource: item, ofType: "obj")!
            meshRecords.append(MeshRecord(name: item, iconName: item, id: SPTCreate3DMeshFromFile(meshPath)))
        }
        for item in ["plane", "circle"] {
            let meshPath = Bundle.main.path(forResource: item, ofType: "obj")!
            meshRecords.append(MeshRecord(name: item, iconName: item, id: SPTCreate2DMeshFromFile(meshPath)))
        }
    }
    
    func recordById(_ id: SPTMeshId) -> MeshRecord? {
        meshRecords.first { $0.id == id }
    }
    
    func recordNamed(_ name: String) -> MeshRecord? {
        meshRecords.first { $0.name == name }
    }
    
    private(set) var meshRecords = [MeshRecord]()
    
}
