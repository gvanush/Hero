//
//  AnimatePositionToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.10.22.
//

import SwiftUI
import Combine


class AnimatePositionToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<PositionAnimatorBindingsComponent> {
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: AnimatePositionToolSelectedObjectViewModel
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: MeshObjectComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
            .padding(.horizontal, 8.0)
            .padding(.bottom, 8.0)
            .background {
                Color.clear
                    .contentShape(Rectangle())
            }
    }
    
}


class AnimatePositionToolViewModel: BasicToolViewModel<AnimatePositionToolSelectedObjectViewModel, PositionAnimatorBindingsComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .animatePosition, sceneViewModel: sceneViewModel)
    }
    
}


struct AnimatePositionToolView: View {
    
    @ObservedObject var model: AnimatePositionToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
