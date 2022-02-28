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
        SPTPositionMakeXYZ(object, .zero)
        SPTOrientationMakeEuler(object, .init(rotation: .zero, order: .XYZ))
        SPTScaleMake(object, .one)
        SPTGeneratorMake(object, meshId, 5)
        
        return object
    }
    
}
