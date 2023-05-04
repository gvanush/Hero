//
//  MoveToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI


fileprivate struct SelectedObjectView: View {
    
    let object: SPTObject
    
    @StateObject private var position: SPTObservableComponent<SPTPosition>
    
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    @State private var originPointObject: SPTObject!
    
    init(object: SPTObject) {
        self.object = object
        _position = .init(wrappedValue: .init(object: object))
    }
    
    var body: some View {
        ElementTreeView(activeIndexPath: $editingParams[tool: .move, object].activeElementIndexPath) {
            
            switch position.coordinateSystem {
            case .cartesian:
                CartesianPositionElement(object: object, keyPath: \SPTPosition.cartesian, position: $position.cartesian)
            case .linear:
                LinearPositionElement(object: object)
            case .cylindrical:
                CylindricalPositionElement(object: object)
            case .spherical:
                SphericalPositionElement(object: object)
            }
            
        }
        .onPreferenceChange(ComponentDisclosedElementsPreferenceKey.self) {
            model[object].disclosedElementsData = $0
        }
        .onChange(of: position.value, perform: { newValue in
            SPTPosition.update(newValue, object: originPointObject)
        })
        .onAppear {
            originPointObject = sceneViewModel.scene.makeObject()
            SPTPosition.make(position.value, object: originPointObject)
            SPTPointLook.make(.init(color: UIColor.primarySelectionColor.rgba, size: .guidePointRegularSize, categories: LookCategories.guide.rawValue), object: originPointObject)
        }
        .onDisappear {
            model[object] = nil
            SPTSceneProxy.destroyObject(originPointObject)
        }
    }
    
}


struct MoveToolView: View {
    
    @ObservedObject var model: BasicToolModel
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var body: some View {
        if let object = sceneViewModel.selectedObject {
            SelectedObjectView(object: object)
                .id(object)
                .environmentObject(model)
        }
    }
}
