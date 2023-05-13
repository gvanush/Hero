//
//  ObjectScaleModelSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.05.23.
//

import SwiftUI

struct ObjectScaleModelSelector: View {
    
    let object: SPTObject
    
    @StateObject private var scaleModel: SPTObservableComponentProperty<SPTScale, SPTScaleModel>
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        
        _scaleModel = .init(wrappedValue: .init(object: object, keyPath: \.model))
    }
    
    var body: some View {
        Menu {
            ForEach(SPTScaleModel.allCases) { model in
                Button {
                    updateScaleModel(model)
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
        .onChange(of: scaleModel.value, perform: { [oldValue = scaleModel.value] _ in
            unbindAnimators(model: oldValue)
        })
    }
    
    private func updateScaleModel(_ model: SPTScaleModel) {
        let scale = SPTScale.get(object: object)
        
        switch model {
        case .XYZ:
            SPTScale.update(.init(x: scale.uniform, y: scale.uniform, z: scale.uniform), object: object)
        case .uniform:
            SPTScale.update(.init(uniform: scale.xyz.minComponent), object: object)
        }
        
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
    
}
