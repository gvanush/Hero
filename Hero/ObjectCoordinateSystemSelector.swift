//
//  ObjectCoordinateSystemSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.05.23.
//

import SwiftUI


struct ObjectCoordinateSystemSelector: View {
    
    let object: SPTObject
    
    @StateObject private var coordinateSystem: SPTObservableComponentProperty<SPTPosition, SPTCoordinateSystem>
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        _coordinateSystem = .init(wrappedValue: .init(object: object, keyPath: \.coordinateSystem))
    }
    
    var body: some View {
        Menu {
            ForEach(SPTCoordinateSystem.allCases) { system in
                Button {
                    updateCoordinateSystem(system)
                } label: {
                    HStack {
                        Text(system.displayName)
                        Spacer()
                        if system == self.coordinateSystem.value {
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
        .onChange(of: coordinateSystem.value, perform: { [oldValue = coordinateSystem.value] _ in
            unbindAnimators(coordinateSystem: oldValue)
        })
    }
    
    func updateCoordinateSystem(_ system: SPTCoordinateSystem) {
        let position = SPTPosition.get(object: object)
        
        switch system {
        case .cartesian:
            SPTPosition.update(position.toCartesian, object: object)
        case .linear:
            SPTPosition.update(position.toLinear(origin: position.origin), object: object)
        case .spherical:
            SPTPosition.update(position.toSpherical(origin: position.origin), object: object)
        case .cylindrical:
            SPTPosition.update(position.toCylindrical(origin: position.origin), object: object)
        }
        
        editingParams[tool: .move, object].activeElementIndexPath = .init(index: 0)
    }
    
    private func unbindAnimators(coordinateSystem: SPTCoordinateSystem) {
        switch coordinateSystem {
        case .cartesian:
            SPTAnimatableObjectProperty.cartesianPositionX.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.cartesianPositionY.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.cartesianPositionZ.unbindAnimatorIfBound(object: object)
        case .linear:
            SPTAnimatableObjectProperty.linearPositionOffset.unbindAnimatorIfBound(object: object)
        case .spherical:
            SPTAnimatableObjectProperty.sphericalPositionLatitude.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.sphericalPositionLongitude.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.sphericalPositionRadius.unbindAnimatorIfBound(object: object)
        case .cylindrical:
            SPTAnimatableObjectProperty.cylindricalPositionLongitude.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.cylindricalPositionRadius.unbindAnimatorIfBound(object: object)
            SPTAnimatableObjectProperty.cylindricalPositionHeight.unbindAnimatorIfBound(object: object)
        }
    }
}
