//
//  ObjectColorModelSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.05.23.
//

import SwiftUI


struct ObjectColorModelSelector<C>: View
where C: SPTInspectableComponent {
    
    let object: SPTObject
    let keyPath: WritableKeyPath<C, SPTColor>
    
    @StateObject private var model: SPTObservableComponentProperty<C, SPTColorModel>
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject, keyPath: WritableKeyPath<C, SPTColor>) {
        self.object = object
        self.keyPath = keyPath
        
        _model = .init(wrappedValue: .init(object: object, keyPath: keyPath.appending(path: \.model)))
    }
    
    var body: some View {
        Menu {
            ForEach(SPTColorModel.allCases) { model in
                Button {
                    updateModel(model)
                } label: {
                    HStack {
                        Text(model.displayName)
                        Spacer()
                        if model == self.model.value {
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
        .onChange(of: model.value, perform: { [oldValue = model.value] _ in
            unbindAnimators(model: oldValue)
        })
    }
    
    private func unbindAnimators(model: SPTColorModel) {
        switch model {
        case .RGB:
            SPTAnimatableObjectProperty.red.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.green.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.blue.unbindAnimatorIfBound(object: object)
        case .HSB:
            SPTAnimatableObjectProperty.hue.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.saturation.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.brightness.unbindAnimatorIfBound(object: object)
        }
    }
    
    private func updateModel(_ model: SPTColorModel) {
        var comp = C.get(object: object)
         
        let color = comp[keyPath: keyPath]
        switch model {
        case .RGB:
            comp[keyPath: keyPath] = color.toRGBA
        case .HSB:
            comp[keyPath: keyPath] = color.toHSBA
        }
        
        C.update(comp, object: object)
        
    }
    
}
