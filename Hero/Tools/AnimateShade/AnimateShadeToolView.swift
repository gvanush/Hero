//
//  AnimateShadeToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 10.11.22.
//

import SwiftUI
import Combine


class AnimateShadeToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<MeshLookAnimatorBindingsComponent> {
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: AnimateShadeToolSelectedObjectViewModel
    
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


class AnimateShadeToolViewModel: BasicToolViewModel<AnimateShadeToolSelectedObjectViewModel, MeshLookAnimatorBindingsComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .animateShade, sceneViewModel: sceneViewModel)
    }
    
}

struct AnimateShadeToolView: View {
    @ObservedObject var model: AnimateShadeToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
