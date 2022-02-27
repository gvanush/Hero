//
//  ObjectFactory.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.02.22.
//

import Foundation
import SwiftUI


struct ObjectFactory {
    
    let scene: SPTScene
    
    func makeGenerator(meshId: SPTMeshId) -> SPTObject {
        let object = scene.makeObject()
        SPTMakePosition(object, .init(variantTag: .XYZ, .init(xyz: .zero)))
        SPTMakeOrientation(object, .init(variantTag: .euler, .init(euler: .init(rotation: .zero, order: .XYZ))))
        SPTMakeScale(object, .one)
        SPTMakeGenerator(object, meshId, 5)
        
        return object
    }
    
}
