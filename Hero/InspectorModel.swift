//
//  InspectorModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11/2/20.
//

import SwiftUI

class InspectorModel: ObservableObject {
    
    let sceneObject: SceneObject
    
    init(sceneObject: SceneObject) {
        self.sceneObject = sceneObject
    }
}
