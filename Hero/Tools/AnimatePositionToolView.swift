//
//  AnimatePositionToolView.swift
//  Hero
//
//  Created by Vanush Grigoryan on 02.10.22.
//

import SwiftUI
import Combine


fileprivate class SelectedObjectViewModel: ObservableObject {
    
    let object: SPTObject
    let sceneViewModel: SceneViewModel
    
    let rootComponent: PositionAnimatorBindingsComponent
    @Published var activeComponent: Component
    
    init(object: SPTObject, sceneViewModel: SceneViewModel) {
        self.object = object
        self.sceneViewModel = sceneViewModel
        
        self.rootComponent = PositionAnimatorBindingsComponent(object: object, sceneViewModel: sceneViewModel, parent: nil)
        self.activeComponent = rootComponent
    }
    
}


fileprivate struct SelectedObjectControlsView: View {
    
    @ObservedObject var model: SelectedObjectViewModel
    
    var body: some View {
        PropertyTreeNavigationVIew(rootComponent: model.rootComponent, activeComponent: $model.activeComponent, actionViewViewProvider: MeshObjectComponentActionViewProvider(), setupViewProvider: CommonComponentSetupViewProvider())
    }
    
}


class AnimatePositionToolViewModel: ToolViewModel {
    
    @Published fileprivate var selectedObjectViewModel: SelectedObjectViewModel?
    
    private var selectedObjectSubscription: AnyCancellable?
    private var activeComponentSubscription: AnyCancellable?
    
    init(sceneViewModel: SceneViewModel) {
        
        super.init(tool: .animatePosition, sceneViewModel: sceneViewModel)
        
        selectedObjectSubscription = sceneViewModel.$selectedObject.sink { [weak self] selected in
            self?.setupSelectedObjectViewModel(object: selected)
        }
        
        setupSelectedObjectViewModel(object: sceneViewModel.selectedObject)
        
    }
    
    override var activeComponent: Component? {
        set {
            guard let selectedObjectViewModel = selectedObjectViewModel else {
                return
            }
            selectedObjectViewModel.activeComponent = newValue ?? selectedObjectViewModel.rootComponent
        }
        get {
            selectedObjectViewModel?.activeComponent
        }
    }
    
    private func setupSelectedObjectViewModel(object: SPTObject?) {
        if let object = object {
            selectedObjectViewModel = .init(object: object, sceneViewModel: sceneViewModel)
            activeComponentSubscription = selectedObjectViewModel!.$activeComponent.sink { [weak self] _ in
                self?.objectWillChange.send()
            }
        } else {
            selectedObjectViewModel = nil
            activeComponentSubscription = nil
        }
    }
    
}


struct AnimatePositionToolView: View {
    
    @ObservedObject var model: AnimatePositionToolViewModel
    
    var body: some View {
        if let selectedObjectVM = model.selectedObjectViewModel {
            SelectedObjectControlsView(model: selectedObjectVM)
        } else {
            EmptyView()
        }
    }
}
