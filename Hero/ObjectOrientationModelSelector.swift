//
//  ObjectOrientationModelSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.05.23.
//

import SwiftUI

struct ObjectOrientationModelSelector: View {
    
    let object: SPTObject
    
    @StateObject private var orientationModel: SPTObservableComponentProperty<SPTOrientation, SPTOrientationModel>
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        
        _orientationModel = .init(wrappedValue: .init(object: object, keyPath: \.model))
    }
    
    var body: some View {
        Menu {
            ForEach(SPTOrientationModel.allCases) { model in
                Button {
                    updateOrientationModel(model)
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
    
    func updateOrientationModel(_ model: SPTOrientationModel) {
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
        
    }
}
