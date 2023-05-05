//
//  OrientToolBarView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 05.05.23.
//

import SwiftUI


fileprivate struct SelectedObjectBarView: View {
    
    let object: SPTObject
    
    @StateObject private var orientationModel: SPTObservableComponentProperty<SPTOrientation, SPTOrientationModel>
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        
        _orientationModel = .init(wrappedValue: .init(object: object, keyPath: \.model))
    }
    
    var body: some View {
        HStack {
            Divider()
            BasicToolNavigationView(tool: .orient, object: object)
            orientationModelSelector()
        }
    }
    
    private func orientationModelSelector() -> some View {
        Menu {
            ForEach(SPTOrientationModel.allCases) { model in
                Button {
                    setOrientationModel(model)
                } label: {
                    HStack {
                        Text(model.displayName)
                        Spacer()
                        if model == self.orientationModel.value {
                            Image(systemName: "checkmark.circle")
                                .imageScale(.small)
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "slider.horizontal.3")
                .imageScale(.medium)
        }
        .buttonStyle(.bordered)
        .shadow(radius: 0.5)
    }
    
    func setOrientationModel(_ model: SPTOrientationModel) {
        let orientation = SPTOrientation.get(object: object)
        
        switch model {
        case .eulerXYZ:
            SPTOrientation.update(orientation.toEulerXYZ, object: object)
        case .eulerXZY:
            SPTOrientation.update(orientation.toEulerXZY, object: object)
        case .eulerYXZ:
            SPTOrientation.update(orientation.toEulerYXZ, object: object)
        case .eulerYZX:
            SPTOrientation.update(orientation.toEulerYZX, object: object)
        case .eulerZXY:
            SPTOrientation.update(orientation.toEulerZXY, object: object)
        case .eulerZYX:
            SPTOrientation.update(orientation.toEulerZYX, object: object)
        default:
            fatalError()
        }
        
        editingParams[tool: .orient, object].activeElementIndexPath = .init(index: 0)
    }
    
}


struct OrientToolBarView: View {
    
    @ObservedObject var model: BasicToolModel
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var body: some View {
        if let object = sceneViewModel.selectedObject {
            SelectedObjectBarView(object: object)
                .transition(.identity)
                .id(object)
                .environmentObject(model)
        }
    }
    
}
