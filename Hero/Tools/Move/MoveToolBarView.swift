//
//  MoveToolBarView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 25.04.23.
//

import SwiftUI


fileprivate struct SelectedObjectBarView: View {
    
    let object: SPTObject
    
    @StateObject private var coordinateSystem: SPTObservableComponentProperty<SPTPosition, SPTCoordinateSystem>
    @EnvironmentObject var model: MoveToolModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        
        _coordinateSystem = .init(wrappedValue: .init(object: object, keyPath: \.coordinateSystem))
    }
    
    var body: some View {
        HStack {
            Divider()
            ScrollView(.horizontal, showsIndicators: false) {
                if let disclosedElementsData = model[object].disclosedElementsData {
                    HStack {
                        ForEach(disclosedElementsData, id: \.id) { data in
                            HStack {
                                if data.id != disclosedElementsData.first!.id {
                                    Image(systemName: "chevron.right")
                                        .imageScale(.large)
                                        .foregroundColor(.secondary)
                                }
                                VStack(alignment: .leading) {
                                    Text(data.title)
                                        .fontWeight(.regular)
                                        .fixedSize()
                                    if let substitle = data.subtitle {
                                        Text(substitle)
                                            .font(.system(.subheadline))
                                            .foregroundColor(Color.secondaryLabel)
                                            .fixedSize()
                                    }
                                }
                            }
                            .onTapGesture {
                                withAnimation {
                                    editingParams[tool: .move, object].activeComponentIndexPath = data.indexPath
                                }
                            }
                        }
                    }
                }
            }
            coordinateSystemSelector()
        }
        .onChange(of: coordinateSystem.value, perform: { [oldValue = coordinateSystem.value] newValue in
            unbindAnimators(coordinateSystem: oldValue)
        })
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
    
    private func coordinateSystemSelector() -> some View {
        Menu {
            ForEach(SPTCoordinateSystem.allCases) { system in
                Button {
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
                    
                    editingParams[tool: .move, object].activeComponentIndexPath = .init(index: 0)
                    
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
    }
    
}


struct MoveToolBarView: View {
    
    @ObservedObject var model: MoveToolModel
    
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
