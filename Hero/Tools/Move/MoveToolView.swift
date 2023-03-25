//
//  MoveToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine


class MoveToolComponentViewProvider: MeshObjectComponentViewProvider<PositionComponent> {
    
    override func viewForRoot(_ root: PositionComponent) -> AnyView? {
        AnyView(PositionComponentView(component: root, viewProvider: self))
    }
    
}

class MoveToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<PositionComponent> {
}

fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: MoveToolSelectedObjectViewModel
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: MoveToolComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
            .padding(.horizontal, 8.0)
            .padding(.bottom, 8.0)
            .background {
                Color.clear
                    .contentShape(Rectangle())
            }
    }
    
}

class MoveToolViewModel: BasicToolViewModel<MoveToolSelectedObjectViewModel, PositionComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .move, sceneViewModel: sceneViewModel)
    }
}

// TODO
fileprivate class CoordinateSystemWrapper: ObservableObject {
    
    let object: SPTObject
    
    @SPTObservedComponentProperty<SPTPosition, SPTCoordinateSystem> var coordinateSystem: SPTCoordinateSystem
    
    init(object: SPTObject) {
        self.object = object
        
        _coordinateSystem = .init(object: object, keyPath: \.coordinateSystem)
        _coordinateSystem.publisher = self.objectWillChange
        
    }
    
}

fileprivate struct SelectedObjectView: View {
    
    private let object: SPTObject
    
    @State private var activeCompIndexPath = IndexPath()
    @StateObject private var coordinateSystemWrapper: CoordinateSystemWrapper
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    @EnvironmentObject var editingParams: ObjectEditingParams
    
    init(object: SPTObject) {
        self.object = object
        _coordinateSystemWrapper = .init(wrappedValue: .init(object: object))
    }
    
    var body: some View {
        CompTreeView(activeIndexPath: $activeCompIndexPath, defaultActionView: { controller in
            ObjectCompActionView(controller: (controller as! any ObjectCompController))
        }) {
            Comp("Position")
                .controller {
                    switch coordinateSystemWrapper.coordinateSystem {
                    case .cartesian:
                        return CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel, editingParams: editingParams)
                    case .linear:
                        return CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel, editingParams: editingParams)
                    case .spherical:
                        return CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel, editingParams: editingParams)
                    case .cylindrical:
                        return CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel, editingParams: editingParams)
                    }
                }
            
        }
        .padding(.horizontal, 8.0)
        .padding(.bottom, 8.0)
        .background {
            Color.clear
                .contentShape(Rectangle())
        }
        .id(object)
    }
    
}


struct MoveToolView: View {
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    var body: some View {
        if let object = sceneViewModel.selectedObject {
            SelectedObjectView(object: object)
        }
    }
}
