//
//  AnimateOrientationToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 09.01.23.
//

import SwiftUI

class AnimateOrientationToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<OrientationAnimatorBindingsComponent> {
}

fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: AnimateOrientationToolSelectedObjectViewModel
    
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


class AnimateOrientationToolViewModel: BasicToolViewModel<AnimateOrientationToolSelectedObjectViewModel, OrientationAnimatorBindingsComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .animateOrientation, sceneViewModel: sceneViewModel)
    }
    
}


struct AnimateOrientationToolView: View {
    
    @ObservedObject var model: AnimateOrientationToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
