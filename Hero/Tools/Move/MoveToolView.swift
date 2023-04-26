//
//  MoveToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI


fileprivate struct SelectedObjectView: View {
    
    let object: SPTObject
    
    @SPTObservedComponent private var position: SPTPosition
    
    @EnvironmentObject var model: MoveToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        _position = .init(object: object)
    }
    
    var body: some View {
        ElementTreeView(activeIndexPath: $editingParams[tool: .move, object].activeComponentIndexPath) {
            
            switch position.coordinateSystem {
            case .cartesian:
                CartesianPositionElement(object: object, keyPath: \SPTPosition.cartesian, position: $position.cartesian)
            case .linear:
                LinearPositionElement(object: object)
            case .cylindrical:
                EmptyElement()
            case .spherical:
                EmptyElement()
            }
            
        }
        .onPreferenceChange(ComponentDisclosedElementsPreferenceKey.self) {
            model[object].disclosedElementsData = $0
        }
        .onDisappear {
            model[object] = nil
        }
    }
    
}


struct MoveToolView: View {
    
    @ObservedObject var model: MoveToolModel
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var body: some View {
        if let object = sceneViewModel.selectedObject {
            SelectedObjectView(object: object)
                .id(object)
                .environmentObject(model)
        }
    }
}
