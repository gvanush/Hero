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

fileprivate struct SelectedObjectView: View {
    
    private let object: SPTObject
    
    @State private var activeCompIndexPath = IndexPath()
    
    @EnvironmentObject var sceneViewModel: SceneViewModel
    
    init(object: SPTObject) {
        self.object = object
    }
    
    var body: some View {
        CompTreeView(activeIndexPath: $activeCompIndexPath, defaultActionView: { controller in
            ObjectCompActionView(controller: (controller as! any ObjectCompController))
        }) {
            
            switch SPTPosition.get(object: object).coordinateSystem {
            case .cartesian:
                Comp("Cartesian") { CartesianPositionCompController(object: object, sceneViewModel: sceneViewModel) }
            case .linear:
                Comp("Linear") {
                    
                }
            case .spherical:
                Comp("Spherical") {
                    
                }
            case .cylindrical:
                Comp("Cylindrical") {
                    
                }
            }
            
        }
        .padding(.horizontal, 8.0)
        .padding(.bottom, 8.0)
        .background {
            Color.clear
                .contentShape(Rectangle())
        }
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
