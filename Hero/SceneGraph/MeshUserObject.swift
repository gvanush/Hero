//
//  MeshUserObject.swift
//  Hero
//
//  Created by Vanush Grigoryan on 24.05.23.
//

import Foundation
import UIKit


final class MeshUserObject: UserObject, MeshObject {
    
    let sptObject: SPTObject
    var name: String
    
    var category: UserObjectCategory {
        .mesh
    }
    
    weak var _parent: (MainScene.AnyUserObject)?
    
    var _children = [MainScene.AnyUserObject]()
    
    var _scene: MainScene!
    
    init(sptObject: SPTObject, number: UInt, meshId: SPTMeshId, position: simd_float3 = .zero, scale: Float = 1.0) {
        
        self.sptObject = sptObject
        self.name = "Mesh.\(number)"
        
        _buildUserObject(position: position, scale: scale)
        _buildMeshObject(meshLook: .init(material: SPTPhongMaterial(color: UIColor.darkGray.sptColor(model: .HSB), shininess: 0.5), meshId: meshId, categories: LookCategories([.renderable, .renderableModel]).rawValue))
    }
    
    init(sptObject: SPTObject, number: UInt, original: MeshUserObject) {
        
        self.sptObject = sptObject
        self.name = "Mesh.\(number)"
        
        _cloneUserObject(original: original.sptObject)
        _cloneMeshObject(original: original.sptObject)
    }
    
    func clone() -> MeshUserObject {
        scene.makeObject {
            .init(sptObject: $0, number: $1, original: self)
        }
    }
    
}
