//
//  AnimateScaleToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 30.12.22.
//

import SwiftUI

class AnimateScaleToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<ScaleAnimatorBindingsComponent> {
}

fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: AnimateScaleToolSelectedObjectViewModel
    
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

class AnimateScaleToolViewModel: BasicToolViewModel<AnimateScaleToolSelectedObjectViewModel, ScaleAnimatorBindingsComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .animateScale, sceneViewModel: sceneViewModel)
    }
    
}

struct AnimateScaleToolView: View {
    
    @ObservedObject var model: AnimateScaleToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
