//
//  ScaleToolBarView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 03.05.23.
//

import SwiftUI


fileprivate struct SelectedObjectBarView: View {
    
    let object: SPTObject
    
    @StateObject private var scaleModel: SPTObservableComponentProperty<SPTScale, SPTScaleModel>
    @EnvironmentObject var model: BasicToolModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        
        _scaleModel = .init(wrappedValue: .init(object: object, keyPath: \.model))
    }
    
    var body: some View {
        HStack {
            Divider()
            BasicToolNavigationView(tool: .scale, object: object)
            coordinateSystemSelector()
        }
        .onChange(of: scaleModel.value, perform: { [oldValue = scaleModel.value] newValue in
            unbindAnimators(model: oldValue)
        })
    }
    
    private func unbindAnimators(model: SPTScaleModel) {
        switch model {
        case .XYZ:
            SPTAnimatableObjectProperty.xyzScaleX.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.xyzScaleY.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.xyzScaleZ.unbindAnimatorIfBound(object: object)
            
        case .uniform:
            SPTAnimatableObjectProperty.uniformScale.unbindAnimatorIfBound(object: object)
        }
    }
    
    private func coordinateSystemSelector() -> some View {
        Menu {
            ForEach(SPTScaleModel.allCases) { model in
                Button {
                    setScaleModel(model)
                } label: {
                    HStack {
                        Text(model.displayName)
                        Spacer()
                        if model == self.scaleModel.value {
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
    
    func setScaleModel(_ model: SPTScaleModel) {
        let scale = SPTScale.get(object: object)
        
        switch model {
        case .XYZ:
            SPTScale.update(.init(x: scale.uniform, y: scale.uniform, z: scale.uniform), object: object)
        case .uniform:
            SPTScale.update(.init(uniform: scale.xyz.minComponent), object: object)
        }
        
        editingParams[tool: .scale, object].activeElementIndexPath = .init(index: 0)
    }
    
}


struct ScaleToolBarView: View {
    
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
