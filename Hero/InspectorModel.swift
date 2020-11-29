//
//  InspectorModel.swift
//  Hero
//
//  Created by Vanush Grigoryan on 11/2/20.
//

import SwiftUI

class InspectorModel: ObservableObject {
    
    let sceneObject: SceneObject
    @Binding var isTopBarVisible: Bool
    
    init(sceneObject: SceneObject, isTopBarVisible: Binding<Bool>) {
        self.sceneObject = sceneObject
        _isTopBarVisible = isTopBarVisible
    }
}
