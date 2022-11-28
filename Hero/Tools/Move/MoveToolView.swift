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
    }
    
}

class MoveToolViewModel: BasicToolViewModel<MoveToolSelectedObjectViewModel, PositionComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .move, sceneViewModel: sceneViewModel)
    }
}


struct MoveToolView: View {
    
    @ObservedObject var model: MoveToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
