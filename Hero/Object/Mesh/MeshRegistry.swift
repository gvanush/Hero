//
//  MeshRegistry.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.02.22.
//

import Foundation


struct MeshRecord: Identifiable {
    let name: String
    let iconName: String
    let id: SPTMeshId
}

struct MeshRegistry {
    
    struct Util {
        
        let xAxisLineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "x_axis_line", ofType: "obj")!)
        let yAxisLineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "y_axis_line", ofType: "obj")!)
        let zAxisLineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "z_axis_line", ofType: "obj")!)
        
        let xAxisHalfLineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "x_axis_half_line", ofType: "obj")!)
        
        let circleOutlineMeshId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "circle_outline", ofType: "obj")!)
        
        let coordinateGridePolylineId = SPTCreatePolylineFromFile(Bundle.main.path(forResource: "coordinate_grid", ofType: "obj")!)
        
        fileprivate init() {}
    }
    
    static let util = Util()
    
    static let standard = {
        
        var registry = MeshRegistry();
        
        for item in ["cube", "cylinder", "cone", "sphere", "torus", "monkey"] {
            let meshPath = Bundle.main.path(forResource: item, ofType: "obj")!
            registry.meshRecords.append(MeshRecord(name: item, iconName: item, id: SPTCreate3DMeshFromFile(meshPath)))
        }
        for item in ["plane", "circle"] {
            let meshPath = Bundle.main.path(forResource: item, ofType: "obj")!
            registry.meshRecords.append(MeshRecord(name: item, iconName: item, id: SPTCreate2DMeshFromFile(meshPath)))
        }
        
        return registry
    } ()
    
    func recordById(_ id: SPTMeshId) -> MeshRecord? {
        meshRecords.first { $0.id == id }
    }
    
    func recordNamed(_ name: String) -> MeshRecord? {
        meshRecords.first { $0.name == name }
    }
    
    private(set) var meshRecords = [MeshRecord]()
    
}
