//
//  OrientToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 27.09.22.
//

import SwiftUI
import Combine

class OrientToolComponentViewProvider: MeshObjectComponentViewProvider<OrientationComponent> {
    
    override func viewForRoot(_ root: OrientationComponent) -> AnyView? {
        AnyView(OrientationComponentView(component: root, viewProvider: self))
    }
    
}

class OrientToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<OrientationComponent> {
}

fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: OrientToolSelectedObjectViewModel
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: OrientToolComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
            .padding(.horizontal, 8.0)
            .padding(.bottom, 8.0)
            .background {
                Color.clear
                    .contentShape(Rectangle())
            }
    }
    
}

class OrientToolViewModel: BasicToolViewModel<OrientToolSelectedObjectViewModel, OrientationComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .orient, sceneViewModel: sceneViewModel)
    }
}


struct OrientToolView: View {
    
    @ObservedObject var model: OrientToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
