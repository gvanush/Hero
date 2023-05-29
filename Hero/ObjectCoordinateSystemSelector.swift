//
//  ObjectCoordinateSystemSelector.swift
//  Hero
//
//  Created by Vanush Grigoryan on 08.05.23.
//

import SwiftUI


struct ObjectCoordinateSystemSelector: View {
    
    @ObservedObject @ObservableAnyUserObject var object: any UserObject
    
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: any UserObject) {
        _object = .init(wrappedValue: .init(wrappedValue: object))
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
                        if system == object.position.coordinateSystem {
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
        .onChange(of: object.position.coordinateSystem, perform: { [oldValue = object.position.coordinateSystem] _ in
            unbindAnimators(coordinateSystem: oldValue)
        })
    }
    
    func updateCoordinateSystem(_ system: SPTCoordinateSystem) {
        
        switch system {
        case .cartesian:
            object.position = object.position.toCartesian
        case .linear:
            object.position = object.position.toLinear(origin: object.position.origin)
        case .spherical:
            object.position = object.position.toSpherical(origin: object.position.origin)
        case .cylindrical:
            object.position = object.position.toCylindrical(origin: object.position.origin)
        }
        
    }
    
    private func unbindAnimators(coordinateSystem: SPTCoordinateSystem) {
        switch coordinateSystem {
        case .cartesian:
            SPTAnimatableObjectProperty.cartesianPositionX.unbindAnimatorIfBound(object: object.sptObject)
            SPTAnimatableObjectProperty.cartesianPositionY.unbindAnimatorIfBound(object: object.sptObject)
            SPTAnimatableObjectProperty.cartesianPositionZ.unbindAnimatorIfBound(object: object.sptObject)
        case .linear:
            SPTAnimatableObjectProperty.linearPositionOffset.unbindAnimatorIfBound(object: object.sptObject)
        case .spherical:
            SPTAnimatableObjectProperty.sphericalPositionLatitude.unbindAnimatorIfBound(object: object.sptObject)
            SPTAnimatableObjectProperty.sphericalPositionLongitude.unbindAnimatorIfBound(object: object.sptObject)
            SPTAnimatableObjectProperty.sphericalPositionRadius.unbindAnimatorIfBound(object: object.sptObject)
        case .cylindrical:
            SPTAnimatableObjectProperty.cylindricalPositionLongitude.unbindAnimatorIfBound(object: object.sptObject)
            SPTAnimatableObjectProperty.cylindricalPositionRadius.unbindAnimatorIfBound(object: object.sptObject)
            SPTAnimatableObjectProperty.cylindricalPositionHeight.unbindAnimatorIfBound(object: object.sptObject)
        }
    }
}
