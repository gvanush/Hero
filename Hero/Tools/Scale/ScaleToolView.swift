//
//  ScaleToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine

class ScaleToolComponentViewProvider: MeshObjectComponentViewProvider<ScaleComponent> {
    
    override func viewForRoot(_ root: ScaleComponent) -> AnyView? {
        AnyView(ScaleComponentView(component: root, viewProvider: self))
    }
    
}

class ScaleToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<ScaleComponent> {
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: ScaleToolSelectedObjectViewModel
    
    @EnvironmentObject var editingParams: ObjectPropertyEditingParams
    @EnvironmentObject var userInteractionState: UserInteractionState
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: ScaleToolComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
            .padding(.horizontal, 8.0)
            .padding(.bottom, 8.0)
            .background {
                Color.clear
                    .contentShape(Rectangle())
            }
    }
    
}

class ScaleToolViewModel: BasicToolViewModel<ScaleToolSelectedObjectViewModel, ScaleComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .scale, sceneViewModel: sceneViewModel)
    }
    
}

struct ScaleToolView: View {
    @ObservedObject var model: ScaleToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
