//
//  ShadeToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 31.10.22.
//

import SwiftUI
import Combine


class ShadeToolComponentViewProvider: MeshObjectComponentViewProvider<ShadeComponent> {
    
    override func viewForRoot(_ root: ShadeComponent) -> AnyView? {
        AnyView(ShadeComponentView(component: root))
    }
    
}


class ShadeToolSelectedObjectViewModel: BasicToolSelectedObjectViewModel<ShadeComponent> {
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: ShadeToolSelectedObjectViewModel
    
    var body: some View {
        ComponentTreeNavigationView(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, viewProvider: ShadeToolComponentViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
    }
    
}


class ShadeToolViewModel: BasicToolViewModel<ShadeToolSelectedObjectViewModel, ShadeComponent> {
    
    init(sceneViewModel: SceneViewModel) {
        super.init(tool: .shade, sceneViewModel: sceneViewModel)
    }
    
}


struct ShadeToolView: View {
    
    @ObservedObject var model: ShadeToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
                .id(selectedObjectVM.object)
        }
    }
}
