//
//  MoveToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI


fileprivate class LinearPositionCompContext {
    
    let originObject: SPTObject
    let directionObject: SPTObject
    
    init(sceneViewModel: SceneViewModel) {
        self.originObject = sceneViewModel.scene.makeObject()
        self.directionObject = sceneViewModel.scene.makeObject()
    }
    
    deinit {
        SPTSceneProxy.destroyObject(originObject)
        SPTSceneProxy.destroyObject(directionObject)
    }
}


fileprivate enum PositionCompContext {
    case cartesian
    case linear(LinearPositionCompContext)
    case spherical
    case cylindrical
}


class MoveToolModel: ObservableObject {
    
    struct Item {
        fileprivate var disclosedCompsData: [DisclosedCompData]?
        fileprivate var positionCompContext: PositionCompContext?
    }
    
    @Published private var items = [SPTObject : Item]()
    
    subscript (object: SPTObject) -> Item! {
        get {
            items[object, default: .init()]
        }
        set {
            items[object] = newValue
        }
    }
    
}


fileprivate struct SelectedObjectView: View {
    
    private let object: SPTObject
    
    @EnvironmentObject var model: MoveToolModel
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
    }
    
    var body: some View {
        CompTreeView(activeIndexPath: $editingParams[tool: .move, object].activeComponentIndexPath, defaultActionView: { controller in
            ObjectCompActionView(object: object, controller: (controller as! (any ObjectCompControllerProtocol)))
        }) {
            
            switch model[object].positionCompContext {
            case .cartesian:
                Comp("Position", subtitle: "Cartesian")
                    .controller {
                        let compKeyPath = \SPTPosition.cartesian
                        return CartesianPositionCompController(
                            compKeyPath: compKeyPath,
                            activeProperty: .init(rawValue: editingParams[componentId: compKeyPath, object].activePropertyIndex)!,
                            object: object,
                            sceneViewModel: sceneViewModel)
                    }
            case .linear(let ctx):
                Comp("Position", subtitle: "Linear") {
                    Comp("Origin")
                        .controller {
                            let compKeyPath = \SPTPosition.linear.origin
                            return CartesianPositionCompController(
                                compKeyPath: compKeyPath,
                                activeProperty: .init(rawValue: editingParams[componentId: compKeyPath, object].activePropertyIndex)!,
                                object: ctx.originObject,
                                sceneViewModel: sceneViewModel)
                        }
                    Comp("Direction")
                        .controller {
                            let compKeyPath = \SPTPosition.linear.direction
                            return CartesianPositionCompController(
                                compKeyPath: compKeyPath,
                                activeProperty: .init(rawValue: editingParams[componentId: compKeyPath, object].activePropertyIndex)!,
                                object: ctx.directionObject,
                                sceneViewModel: sceneViewModel)
                        }
                }
                .controller {
                    LinearPositionCompController(compKeyPath: \SPTPosition.linear,
                                                 object: object,
                                                 params: .init(sceneViewModel: sceneViewModel, origin: ctx.originObject, direction: ctx.directionObject))
                }
            case .spherical:
                ()
            case .cylindrical:
                ()
            case .none:
                ()
            }
            
        }
        .padding(.horizontal, 8.0)
        .padding(.bottom, 8.0)
        .background {
            Color.clear
                .contentShape(Rectangle())
        }
        .onPreferenceChange(DisclosedCompsPreferenceKey.self, perform: {
            model[object].disclosedCompsData = $0
        })
        .onPreferenceChange(ActiveCompPropertyChangePreferenceKey.self, perform: { data in
            
            guard let data = data else {
                return
            }
            
            let controller = data.controller as! (any ObjectCompControllerProtocol)
            editingParams[componentId: controller.compId, object].activePropertyIndex = controller.activePropertyIndex!
        })
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
                if let disclosedCompsData = model[object].disclosedCompsData {
                    HStack {
                        ForEach(disclosedCompsData, id: \.compId) { data in
                            HStack {
                                if data.compId != disclosedCompsData.first!.compId {
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
            update(coordinateSystem: newValue)
        })
        .onAppear {
            update(coordinateSystem: coordinateSystem.value)
        }
    }
    
    private func update(coordinateSystem: SPTCoordinateSystem) {
        
        switch coordinateSystem {
        case .cartesian:
            model[object].positionCompContext = .cartesian
        case .linear:
            model[object].positionCompContext = .linear(.init(sceneViewModel: sceneViewModel))
        case .spherical:
            model[object].positionCompContext = .spherical
        case .cylindrical:
            model[object].positionCompContext = .cylindrical
        }
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
                    
                    editingParams[tool: .move, object].activeComponentIndexPath = .init()
                    
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
