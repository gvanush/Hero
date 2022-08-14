//
//  SampleSceneData.swift
//  Hero
//
//  Created by Vanush Grigoryan on 06.02.22.
//

import Foundation


struct SampleSceneData {
    
    let sceneViewModel = SceneViewModel()
    
    func makeGenerator(sourceMeshName: String, quantity: UInt16) -> SPTObject {
        let object = sceneViewModel.scene.makeObject()
        SPTGenerator.make(.init(quantity: quantity, sourceMeshId: MeshRegistry.standard.recordNamed(sourceMeshName)!.id), object: object)
        return object
    }
    
}
